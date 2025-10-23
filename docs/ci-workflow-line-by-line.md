# Explicación detallada de `.github/workflows/ci.yml`

Este archivo define el pipeline de GitHub Actions que ejecuta las pruebas del backend y el frontend. A continuación se detalla cada instrucción.

## Encabezado
- `name: CI`
  - Asigna un nombre descriptivo al workflow; se muestra en la pestaña **Actions** de GitHub.

## Disparadores (`on:`)
- `on:` comienza la configuración de eventos que activan el workflow.
- `push:` indica que se ejecutará ante cualquier `git push`.
  - `branches: - main` restringe la ejecución a pushes dirigidos a la rama `main`.
- `pull_request:` agrega el disparador para PRs.
  - `branches: - main` limita a PRs cuyo objetivo es `main`.

## Definición de jobs
- `jobs:` agrupa los trabajos que se ejecutarán en paralelo (por defecto) dentro del workflow.

### Job `test-backend`
- `test-backend:` etiqueta del primer job.
- `runs-on: ubuntu-latest`
  - GitHub provisiona una VM Linux Ubuntu con herramientas preinstaladas.
- `defaults: run: working-directory: backend`
  - Todas las acciones `run:` de este job se ejecutarán dentro del subdirectorio `backend/` del repositorio.

#### Servicio de Postgres
- `services:` define contenedores auxiliares que se levantan junto a la VM.
- `postgres:` nombra el servicio; la app se conectará a este contenedor.
  - `image: postgres:16` descarga la imagen oficial de Postgres versión 16.
  - `env:` establece variables de entorno dentro del contenedor (usuario, clave y base `sticct_test`).
  - `ports: - 5432:5432` expone el puerto 5432 del contenedor hacia la VM; permite que la app Nest acceda vía `localhost:5432`.
  - `options: >- ...`
    - Configura chequeos de salud: `pg_isready` se ejecuta cada 10 segundos con timeout de 5, reintenta 5 veces. Así el job espera a que Postgres acepte conexiones antes de ejecutar los tests.

#### Variables de entorno para el job
- `env:` en este nivel inyecta variables para todos los pasos del job.
  - Se forzan `NODE_ENV=test` y credenciales de BD compatibles con `.env.test`.

#### Pasos (`steps:`)
- `steps:` enumera acciones secuenciales.
  1. `- name: Checkout`
     - `uses: actions/checkout@v4`
       - Clona el repositorio dentro de la VM (paso necesario para trabajar con el código fuente).
  2. `- name: Use Node.js 20`
     - `uses: actions/setup-node@v4` instala Node.
     - `with:` especifica configuración:
       - `node-version: 20` fija la versión.
       - `cache: npm` habilita cache de dependencias.
       - `cache-dependency-path: backend/package-lock.json` utiliza el lockfile del backend para invalidar el cache cuando cambien las dependencias.
  3. `- name: Install dependencies`
     - `run: npm ci`
       - Instala dependencias de forma limpia (preferido en CI).
  4. `- name: Run e2e tests`
     - `run: npm run test:e2e`
       - Lanza Jest con la configuración `backend/test/jest-e2e.json`, conectándose al servicio Postgres definido arriba.
  5. `- name: Run unit tests with coverage`
     - `run: npm run test:cov`
       - Ejecuta las pruebas unitarias del backend con generación de reportes de cobertura. Jest genera archivos de cobertura en formato LCOV en el directorio `backend/coverage/`.
  6. `- name: Upload coverage to Codecov`
     - `uses: codecov/codecov-action@v4`
       - Utiliza la acción oficial de Codecov para subir los reportes de cobertura de código.
     - `with:`
       - `files: 'backend/coverage/lcov.info'` especifica la ruta al archivo de cobertura generado por Jest.
       - `flags: backend` etiqueta este reporte como perteneciente al backend para separarlo del frontend en Codecov.
       - `fail_ci_if_error: true` hace que el job falle si hay problemas subiendo la cobertura a Codecov.

### Job `test-frontend`
- `test-frontend:` segundo job, se ejecuta en paralelo al backend.
- `runs-on: ubuntu-latest`
  - Reutiliza la imagen base de GitHub.
- `defaults: run: working-directory: frontend`
  - Cambia el directorio predeterminado a `frontend/`.
- `steps:`
  1. Checkout y setup de Node idénticos al job anterior, salvo que ahora `cache-dependency-path` apunta a `frontend/package-lock.json`.
  2. `npm ci` instala dependencias del frontend.
  3. `- name: Run unit tests with coverage`
     - `run: npm run test:cov`
       - Ejecuta las pruebas unitarias de Angular con generación de reportes de cobertura usando Karma y Jest. Los reportes se generan en el directorio `frontend/coverage/`.
     - `env:`
       - `CI: true` desactiva prompts interactivos en CLI de Angular/Karma y habilita el modo de ejecución única (sin watch).
       - `CHROME_BIN: /usr/bin/google-chrome` define la ruta del navegador preinstalado en la VM (Angular lo necesita para lanzar Chrome Headless).
  4. `- name: Upload frontend coverage`
     - `uses: codecov/codecov-action@v4`
       - Sube los reportes de cobertura del frontend a Codecov.
     - `with:`
       - `files: 'frontend/coverage/sti-cct/lcov.info'` especifica la ruta al archivo de cobertura generado por Angular (el subdirectorio `sti-cct` corresponde al nombre del proyecto Angular).
       - `flags: frontend` etiqueta este reporte como perteneciente al frontend para diferenciarlo del backend en Codecov.
       - `fail_ci_if_error: true` hace que el job falle si hay errores al subir la cobertura.

## Resumen
Este workflow asegura que cada push o PR a `main` dispare pruebas e2e del backend frente a una base Postgres real y pruebas unitarias del frontend en un entorno consistente. Los servicios, variables y caches están alineados con los archivos del repositorio (`backend/package.json`, `frontend/package.json`, `.env.test`).
