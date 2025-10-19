# STI App Monorepo

Proyecto full stack con un backend NestJS y un frontend Angular, listos para ejecutarse juntos mediante Docker o manualmente en cualquier equipo.

## Estructura

```
.
├── backend/        # API NestJS + TypeORM + PostgreSQL
├── frontend/       # Aplicación Angular
├── docker-compose.yml
└── .github/workflows/ci.yml
```

## Requisitos

- Node.js 18 o superior (se recomienda 20)
- npm 9+
- Docker y Docker Compose (opcional pero recomendado para levantar toda la pila)

## Puesta en marcha rápida con Docker

```powershell
# En la raíz del repositorio
docker compose up --build
```

Servicios disponibles:
- API NestJS: http://localhost:3000
- Angular: http://localhost:4200
- PostgreSQL: puerto 5432 (usuario `postgres`, password `secret123!`)
- Adminer: http://localhost:8080 (opcional)

## Configuración manual

### Backend

```powershell
cd backend
cp .env.example .env      # Ajusta valores si es necesario
cp .env.test.example .env.test
npm install
npm run start:dev
```

El servidor queda disponible en `http://localhost:3000`. Para ejecutar las pruebas de integración:

```powershell
npm run test:e2e
```

Estos tests esperan un PostgreSQL accesible en `localhost:5432` con la base `sticct_test`. Puedes reutilizar el contenedor de Docker Compose o levantar tu propio servicio.

### Frontend

```powershell
cd frontend
npm install
npm run start
```

La aplicación se servirá en `http://localhost:4200`.

## Flujo de integración continua

El workflow `Backend CI` ejecuta las pruebas e2e del backend contra un contenedor de PostgreSQL en cada push y pull request hacia `main`.

```text
.github/workflows/ci.yml
```

Al mismo tiempo, el job `test-frontend` compila dependencias de Angular y corre las pruebas unitarias en Chrome Headless, por lo que cualquier push a `main` disparará ambos chequeos automáticamente.

## Scripts útiles

| Ubicación | Comando            | Descripción                             |
|-----------|--------------------|-----------------------------------------|
| backend   | `npm run start:dev`| Levanta NestJS con hot reload            |
| backend   | `npm run test:e2e` | Ejecuta pruebas de integración           |
| frontend  | `npm run start`    | Levanta la app Angular (ng serve)        |
| raíz      | `docker compose up`| Levanta toda la pila (backend + frontend + DB) |

## Siguientes pasos sugeridos

[![codecov](https://codecov.io/github/Aleisistan/sti-app-desarrollo-worflow/graph/badge.svg?token=161ACLIY2M)](https://codecov.io/github/Aleisistan/sti-app-desarrollo-worflow)
- Documentar endpoints adicionales en `backend/README.md`.
- Añadir pipelines específicos para el frontend si lo necesitas.
- Configurar seeds/migraciones si quieres partir con datos iniciales.
