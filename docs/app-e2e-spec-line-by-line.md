# Explicación detallada `backend/test/app.e2e-spec.ts`

Este documento detalla el propósito de cada línea del archivo de pruebas end-to-end del backend y referencia los módulos locales involucrados.

## Importaciones iniciales
- `import { INestApplication, ValidationPipe } from '@nestjs/common';`
  - Trae tipos y utilidades del core de NestJS. `INestApplication` tipa la instancia de la app creada para pruebas y `ValidationPipe` replica la validación global configurada en producción. Ambos provienen del paquete `@nestjs/common` (dep declarado en `backend/package.json`).
- `import { Test } from '@nestjs/testing';`
  - Usa el módulo de testing oficial de Nest para generar un módulo de pruebas; referencia local implícita: `AppModule` se compila mediante este helper.
- `import { config as loadEnv } from 'dotenv';`
  - Carga variables de entorno desde un archivo `.env`. La función se renombra a `loadEnv` para claridad en el código.
- `import { join } from 'path';`
  - Permite construir rutas portables (Windows/Linux) para ubicar `.env.test` relativo a este archivo.
- `import * as request from 'supertest';`
  - Cliente HTTP que opera sobre `app.getHttpServer()` para ejecutar peticiones reales durante los tests.
- `import { DataSource } from 'typeorm';`
  - Tipo principal de TypeORM que expone repositorios (`getRepository`) y permite ejecutar consultas directas (se usa en `clearDatabase`).
- `import { AppModule } from '../src/app.module';`
  - Carga el módulo raíz del backend (`backend/src/app.module.ts`) para crear la app Nest completa dentro del ambiente de pruebas.
- `import { Order } from '../src/orders/entities/order.entity';`
  - Entidad TypeORM que mapea la tabla de órdenes; archivo localizado en `backend/src/orders/entities/order.entity.ts`.
- `import { User } from '../src/users/entities/user.entity';`
  - Entidad TypeORM para usuarios, definida en `backend/src/users/entities/user.entity.ts`.

## Estructura del describe principal
- `describe('AppController (e2e)', () => {` define el bloque global de pruebas end-to-end.
- `let app: INestApplication;` declara una variable para la instancia Nest construida en `beforeAll`.
- `let dataSource: DataSource;` almacenará la conexión TypeORM que expone repositorios y query builders durante las pruebas.

## `beforeAll` – configuración previa
- `beforeAll(async () => {` ejecuta lógica asíncrona antes de cualquier test.
- `process.env.NODE_ENV = 'test';` ajusta explícitamente el modo de ejecución para que `AppModule` cargue `.env.test` (lógica en `backend/src/app.module.ts`).
- `loadEnv({ path: join(__dirname, '..', '.env.test') });` carga variables declaradas en `backend/test/.env.test` usando una ruta absoluta construida con `join` (se sube un nivel desde `test/`).
- Bloque de asignaciones `process.env.DB_* = process.env.DB_* || ...;`
  - Garantiza valores por defecto si la variable no estaba definida; mantiene la compatibilidad con los contenedores y con la ejecución local (host `localhost`, credenciales `postgres/secret123!`, base `sticct_test`).
- `const moduleFixture = await Test.createTestingModule({ imports: [AppModule], }).compile();`
  - Construye un módulo de pruebas que importa `AppModule`, compila la estructura de dependencias y devuelve un `TestingModule`.
- `app = moduleFixture.createNestApplication();`
  - Instancia la aplicación NestJS completa sobre el módulo compilado.
- `app.useGlobalPipes(new ValidationPipe({...}));`
  - Replica los pipes globales de producción: `whitelist` elimina propiedades no permitidas por los DTO, `forbidNonWhitelisted` lanza 400 si aparecen, y `transform` convierte payloads a clases DTO. Referencia local: DTOs en `backend/src/users/dto/...` y `backend/src/orders/dto/...` que usan decoradores `class-validator`.
- `await app.init();` levanta la app en memoria sin necesidad de escuchar un puerto real.
- `dataSource = app.get(DataSource);` obtiene la instancia TypeORM inyectada por `AppModule` (configurada con Postgres en `backend/src/app.module.ts`).
- `await clearDatabase(dataSource);` ejecuta la función auxiliar definida al final del archivo para limpiar tablas `Order` y `User` antes de cualquier caso de prueba.

## Hooks posteriores
- `afterEach(async () => { await clearDatabase(dataSource); });`
  - Garantiza que cada caso de prueba se ejecute sobre una base vacía para evitar dependencias entre tests.
- `afterAll(async () => { await app.close(); });`
  - Cierra la aplicación Nest y libera la conexión a la base de datos al finalizar la suite.

## Bloque `/users (POST)`
- `describe('/users (POST)', () => { ... });` agrupa los escenarios del endpoint de creación de usuarios.
- Primer `it`: **creación exitosa**
  - `const createUserDto = {...};` define el payload esperado por `UsersController` (`backend/src/users/users.controller.ts`), acorde al DTO `CreateUsersDto` (`backend/src/users/dto/create-users.dto/create-users.dto.ts`).
  - `request(app.getHttpServer()).post('/users').send(createUserDto).expect(201);`
    - Envía la petición HTTP contra el servidor http in-memory de NestJS.
  - `expect(response.body).toMatchObject({...});`
    - Verifica que la respuesta contenga los campos persistidos y que `isActive` por defecto sea `true` (propiedad definida en la entidad `User`).
  - `expect(response.body).toHaveProperty('id');`
    - Comprueba que TypeORM asignó un identificador entero (columna `@PrimaryGeneratedColumn()` en `user.entity.ts`).
- Segundo `it`: **validación de email obligatorio**
  - Define un DTO sin `mail` y espera un estado `400`. Esto depende de la validación en `CreateUsersDto` (`@IsEmail()` y `@IsNotEmpty()`).

## Bloque `/orders (POST)`
- `describe('/orders (POST)', () => { ... });` cubre el endpoint de creación de órdenes.
- Primer `it`: **orden válida con prioridad**
  - `const userRepository = dataSource.getRepository(User);` obtiene el repositorio para interactuar con la tabla `users` directamente (TypeORM expone `Repository<User>` a través del `DataSource`).
  - `const user = await userRepository.save({...});` inserta un usuario de apoyo; se requiere porque `OrdersService` valida `createOrderDto.userId` contra un usuario existente (ver `backend/src/orders/orders.service.ts`).
  - `const createOrderDto = {...};` respeta el esquema de `CreateOrdersDto` (`backend/src/orders/dto/create-orders.dto.ts`).
  - `request(...).post('/orders').send(createOrderDto).expect(201);` envía la solicitud POST.
  - `expect(response.body).toMatchObject({...});` valida los campos principales devueltos por `OrdersController`.
  - `expect(response.body).toHaveProperty('id');` confirma que se generó un ID.
  - `const persistedOrder = await dataSource.getRepository(Order).findOne({ where: { id: response.body.id }, relations: ['user'] });`
    - Recupera la orden desde la base incluyendo la relación con el usuario (`relations: ['user']`) para verificar integridad.
  - Assert finales comprueban que la orden existe, mantiene la prioridad y referencia al usuario creado.
- Segundo `it`: **orden sin prioridad**
  - Vuelve a persistir un usuario auxiliar.
  - Genera `invalidOrderDto` sin campo `priority`.
  - Espera `400`, validando las reglas de `CreateOrdersDto` (`@IsString() @IsNotEmpty()` en `priority`).

## Función auxiliar `clearDatabase`
- `async function clearDatabase(source: DataSource): Promise<void> { ... }`
  - Ubicada al final del archivo para que los hooks la utilicen.
- `await source.createQueryBuilder().delete().from(Order).execute();`
  - Emite un `DELETE FROM order` (respeta FKs borrando órdenes antes que usuarios). Utiliza `QueryBuilder` para no necesitar criterios explícitos.
- `await source.createQueryBuilder().delete().from(User).execute();`
  - Limpia la tabla `user`, dejando la base lista para el siguiente escenario.

## Referencias cruzadas clave
- `backend/src/app.module.ts` configura TypeORM (Postgres) y registra entidades `Order` y `User`.
- DTOs con validaciones:
  - `backend/src/users/dto/create-users.dto/create-users.dto.ts`
  - `backend/src/orders/dto/create-orders.dto.ts`
- Controladores que reciben las peticiones testeadas:
  - `backend/src/users/users.controller.ts`
  - `backend/src/orders/orders.controller.ts`
- Servicios que implementan la lógica de negocio validada por estas pruebas:
  - `backend/src/users/users.service.ts`
  - `backend/src/orders/orders.service.ts`

Con esto se puede rastrear cada dependencia y entender cómo las pruebas e2e ejercitan la API completa a través del módulo raíz `AppModule`.
