# 🔒 Security Vulnerability Management

Este documento explica cómo manejar las vulnerabilidades de seguridad en el proyecto STI API.

## 🚨 ¿Por qué falla el CI?

El CI puede fallar por dos razones principales:

1. **Vulnerabilidades de seguridad**: `npm audit` encuentra vulnerabilidades conocidas
2. **Lock file desincronizado**: `package.json` y `package-lock.json` no están sincronizados

### Error común: `EUSAGE npm ci`
```
npm error `npm ci` can only install packages when your package.json and package-lock.json are in sync
```

**Solución**: Ejecutar `npm install` para sincronizar los archivos.

## 🛠️ Cómo solucionarlo

### Opción 1: Script Automático (Recomendado)

**Windows (PowerShell):**
```powershell
.\fix-vulnerabilities.ps1 all
```

**Linux/Mac (Bash):**
```bash
chmod +x fix-vulnerabilities.sh
./fix-vulnerabilities.sh all
```

### Opción 2: Manual

#### Backend:
```bash
cd backend
npm audit --audit-level moderate
npm audit fix
npm audit --audit-level moderate
```

#### Frontend:
```bash
cd frontend
npm audit --audit-level moderate
npm audit fix
npm audit --audit-level moderate
```

### Opción 3: Forzar arreglos (⚠️ Cuidado)
```bash
npm audit fix --force
```
**Nota:** Esto puede introducir cambios breaking. Úsalo solo si entiendes las consecuencias.

## 🔧 Solucionando problemas de Lock File

### Si aparece error `EUSAGE npm ci`:

**Frontend:**
```bash
cd frontend
npm install  # Esto actualizará package-lock.json
npm audit fix
```

**Backend:**
```bash
cd backend  
npm install  # Si es necesario
npm audit fix
```

### ¿Por qué ocurre?
- Se agregaron nuevas dependencias al `package.json`
- El `package-lock.json` no se actualizó
- `npm ci` requiere que ambos archivos estén sincronizados

## 📊 Entendiendo los niveles de vulnerabilidad

- **Low**: Impacto menor, no crítico
- **Moderate**: Impacto medio, debe ser atendido
- **High**: Impacto alto, prioridad alta
- **Critical**: Impacto crítico, atender inmediatamente

## 🔧 Scripts disponibles

### Backend:
- `npm run security:check` - Verifica vulnerabilidades
- `npm run security:fix` - Intenta arreglar automáticamente
- `npm run security:fix-force` - Fuerza arreglos (⚠️ cuidado)
- `npm run security:report` - Genera reporte JSON

## 🎯 Estrategia del CI

El CI ahora está configurado para:

1. **Reportar vulnerabilidades** sin fallar el build
2. **Intentar arreglos automáticos** de vulnerabilidades no-breaking
3. **Continuar con los tests** incluso si hay vulnerabilidades menores
4. **Fallar solo en vulnerabilidades críticas** que impidan el funcionamiento

## 🏆 Mejores prácticas

1. **Actualiza regularmente** las dependencias
2. **Revisa los reportes** de vulnerabilidades semanalmente
3. **Prioriza vulnerabilidades** según su severidad e impacto real
4. **Testea después** de arreglar vulnerabilidades
5. **Documenta excepciones** para falsos positivos

## 🚀 Si el CI sigue fallando

1. Ejecuta los scripts de arreglo localmente
2. Commit y push los cambios
3. Si persiste, revisa las vulnerabilidades específicas
4. Considera actualizar dependencias manualmente

### Problemas de Integration Tests

Si los **integration tests** fallan con errores de conexión:

**Probar localmente:**
```bash
# Linux/Mac
chmod +x test-integration.sh
./test-integration.sh

# Windows
test-integration.bat
```

**Problemas comunes:**
- Backend no inicia: Verificar `npm run start` en `/backend`
- Puerto 3000 ocupado: Matar procesos `netstat -tulpn | grep :3000`
- Base de datos no disponible: Verificar PostgreSQL corriendo
- Health endpoint no responde: Verificar `/health` en `app.controller.ts`

### ¿Por qué usar modo desarrollo en tests?

Los **integration tests** ahora usan `npm run start` (desarrollo) en lugar de `npm run start:prod` porque:

✅ **Más rápido**: No requiere compilación previa  
✅ **Más apropiado**: Testing no es producción  
✅ **Mejor debugging**: Source maps y error traces más claros  
✅ **Menos pasos**: Elimina el paso de build  

**Comparación:**
```bash
# ❌ Antes (modo producción)
npm run build    # Compilar TypeScript
npm run start:prod    # Ejecutar JS compilado

# ✅ Ahora (modo desarrollo)  
npm run start    # Ejecutar TypeScript directamente
```

## 📞 Necesitas ayuda?

- Revisa los logs del CI para vulnerabilidades específicas
- Busca en npm/GitHub si hay actualizaciones disponibles
- Considera alternativas para dependencias problemáticas