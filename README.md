# STI App - Sistema de Desarrollo con CI/CD Avanzado

Proyecto completo con backend NestJS y frontend Angular, con **pipeline de CI/CD robusto** que incluye linting, tests de seguridad, integración completa y containerización automáticamente.

[![codecov](https://codecov.io/github/Aleisistan/sti-app-desarrollo-worflow/graph/badge.svg?token=161ACLIY2M)](https://codecov.io/github/Aleisistan/sti-app-desarrollo-worflow)
[![CI](https://github.com/Aleisistan/sti-app-desarrollo-worflow/actions/workflows/ci.yml/badge.svg)](https://github.com/Aleisistan/sti-app-desarrollo-worflow/actions/workflows/ci.yml)

## 🚀 Características Principales

- ✅ **Backend NestJS** + TypeORM + PostgreSQL
- ✅ **Frontend Angular** con SSR
- ✅ **Pipeline CI/CD completo** con múltiples tipos de testing
- ✅ **Linting automatizado** (ESLint + TypeScript)
- ✅ **Gestión de vulnerabilidades** automatizada
- ✅ **Tests de integración** end-to-end
- ✅ **Docker containerización** validada
- ✅ **Health checks** y monitoring
- ✅ **Cobertura de código** automatizada

## 📁 Estructura del Proyecto

```
.
├── backend/              # API NestJS + TypeORM + PostgreSQL
├── frontend/             # Aplicación Angular con SSR
├── docs/                 # Documentación del proyecto
├── .github/workflows/    # Pipeline CI/CD
├── docker-compose.yml    # Orchestración de contenedores
├── scripts/              # Utilidades automatizadas (fix/test)
│   ├── fix/              # Scripts de remediación
│   └── test/             # Scripts de testing local
├── SECURITY.md          # Guía de seguridad
└── CI-CD-IMPROVEMENTS-*.md # Documentación de mejoras
```

## Requisitos

- Node.js 18 o superior (se recomienda 20)
- npm 9+
- Docker y Docker Compose (opcional pero recomendado para levantar toda la pila)

## ⚡ Puesta en marcha rápida con Docker

```bash
# En la raíz del repositorio
docker compose up --build
```

**Servicios disponibles:**
- 🔗 **API NestJS**: http://localhost:3000
- 🌐 **Angular App**: http://localhost:4200  
- 🔗 **Health Check**: http://localhost:3000/health
- 🗄️ **PostgreSQL**: puerto 5432 (usuario `postgres`, password `secret123!`)
- 🔧 **Adminer**: http://localhost:8080 (administración DB)

## 🛠️ Configuración manual

### Backend (NestJS)

```bash
cd backend
cp .env.example .env      # Ajusta valores si es necesario
cp .env.test.example .env.test
npm install
npm run start:dev         # Desarrollo con hot reload
```

**Comandos adicionales:**
```bash
npm run lint             # Verificar código
npm run test:e2e         # Tests de integración
npm run security:check   # Auditar vulnerabilidades
```

### Frontend (Angular)

```bash
cd frontend
npm install
npm run start            # Desarrollo (ng serve)
```

**Comandos adicionales:**
```bash
npm run lint             # Verificar código
npm run build            # Build para producción
npm run test:cov         # Tests con cobertura
```

## 🔄 Pipeline de CI/CD

Nuestro pipeline automatizado incluye **4 jobs principales**:

### 1. 🧪 **test-backend**
- ✅ Instalación de dependencias
- ✅ **Auditoría de seguridad** (no-bloqueante)
- ✅ **Linting automático** (ESLint + TypeScript)
- ✅ Tests E2E con PostgreSQL
- ✅ Tests unitarios + cobertura
- ✅ Upload a Codecov

### 2. 🌐 **test-frontend**  
- ✅ Instalación con fallback automático
- ✅ **Auditoría de seguridad** 
- ✅ **Linting Angular** (ESLint + templates)
- ✅ Tests unitarios + cobertura
- ✅ **Verificación de build**
- ✅ Upload a Codecov

### 3. 🐳 **docker-build-test**
- ✅ Validación de Dockerfile backend
- ✅ Validación de Dockerfile frontend
- ✅ Tests básicos de contenedores

### 4. 🔗 **integration-tests**
- ✅ Orchestración completa (Backend + Frontend + DB)
- ✅ **Health checks automáticos**
- ✅ **Smoke tests** de conectividad
- ✅ Modo desarrollo optimizado (50% más rápido)

## 🔧 Scripts de Automatización

### 🔒 **Gestión de Vulnerabilidades**
```bash
# Windows
.\scripts\fix\fix-vulnerabilities.ps1 all

# Linux/Mac  
./scripts/fix/fix-vulnerabilities.sh all

# Solo frontend (Windows)
.\scripts\fix\fix-frontend.bat
```

### 🧪 **Testing Local de Integración**
```bash
# Windows
.\scripts\test\test-integration.bat

# Linux/Mac
chmod +x scripts/test/test-integration.sh
./scripts/test/test-integration.sh
```

### 🛠️ **Scripts por Proyecto**

#### Backend
```bash
npm run security:check      # Auditar vulnerabilidades  
npm run security:fix        # Arreglar automáticamente
npm run security:fix-force  # Forzar arreglos (⚠️ cuidado)
npm run test:integration    # Tests de integración
```

#### Frontend  
```bash
npm run lint               # Verificar código y templates
ng lint                   # Mismo comando, directo
npm run build             # Build optimizado
```

## 📋 Referencia Rápida de Comandos

| 🎯 Propósito | 📍 Ubicación | 💻 Comando | 📝 Descripción |
|-------------|-------------|------------|---------------|
| **Desarrollo** | backend | `npm run start:dev` | NestJS con hot reload |
| **Desarrollo** | frontend | `npm run start` | Angular dev server |
| **Todo** | raíz | `docker compose up --build` | Stack completo |
| **Linting** | backend | `npm run lint` | ESLint + fix automático |
| **Linting** | frontend | `npm run lint` | ESLint Angular + templates |
| **Testing** | backend | `npm run test:e2e` | Tests integración + DB |
| **Testing** | frontend | `npm run test:cov` | Tests + cobertura |
| **Seguridad** | raíz | `.\scripts\fix\fix-vulnerabilities.ps1 all` | Fix vulnerabilidades |
| **Integración** | raíz | `.\scripts\test\test-integration.bat` | Test local completo |
| **Health** | - | `curl http://localhost:3000/health` | Estado del backend |

## 🚨 Troubleshooting

### ❌ **CI falla por vulnerabilidades**
```bash
# 1. Ejecutar fix local
.\scripts\fix\fix-vulnerabilities.ps1 all

# 2. Commit y push
git add . && git commit -m "fix: security vulnerabilities"
git push
```

### ❌ **Error: lock files desincronizados**
```bash
cd frontend
npm install  # Actualiza package-lock.json
```

### ❌ **Integration tests fallan**
```bash
# Verificar servicios localmente
.\scripts\test\test-integration.bat  # Windows
./scripts/test/test-integration.sh # Linux/Mac
```

### ❌ **Puerto 3000/4200 ocupado**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```
# API Deployada

## Frontend : https://sti-app-desarrollo-workflow.onrender.com/home
## Backend : https://sti-api.onrender.com/
## DB : https://supabase.com/dashboard/project/nqyhaykxsrgnyvsfwpgx
## Docker Hub: https://hub.docker.com/repository/docker/alejandrotoloza/sti-api/general

## 📚 Documentación Adicional

- 📖 **[Mejoras CI/CD](CI-CD-IMPROVEMENTS-2025-10-24.md)** - Documentación completa de mejoras
- 🔒 **[Guía de Seguridad](SECURITY.md)** - Gestión de vulnerabilidades  
- 🧪 **[Testing Strategy](docs/TESTING-STRATEGY.md)** - Portafolio completo de tests automatizados y manuales
- 📁 **[Docs del proyecto](docs/)** - Documentación técnica detallada

## 🎯 Próximas Mejoras Sugeridas

- [ ] **Lighthouse CI** para métricas de performance
- [ ] **Cypress E2E** tests más robustos  
- [ ] **SonarQube** análisis de código
- [ ] **API testing** con Postman/Newman
- [ ] **Load testing** con Artillery
- [ ] **Multi-browser** testing
- [ ] **Blue-green** deployment

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. **Ejecutar linting**: `npm run lint` en ambos proyectos
4. **Ejecutar tests**: Verificar que pasen todos los tests
5. **Verificar seguridad**: `.\scripts\fix\fix-vulnerabilities.ps1 all`
6. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
7. Push a la rama (`git push origin feature/AmazingFeature`)
8. Abrir Pull Request

---

**🎉 ¡Pipeline robusto y automatizado listo para desarrollo profesional!**
