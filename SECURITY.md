# 🔒 Security Vulnerability Management

Este documento explica cómo manejar las vulnerabilidades de seguridad en el proyecto STI API.

## 🚨 ¿Por qué falla el CI?

El CI puede fallar cuando `npm audit` encuentra vulnerabilidades de seguridad. Esto es **normal y esperado** en proyectos Node.js, especialmente con dependencias que tienen vulnerabilidades conocidas.

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

## 📞 Necesitas ayuda?

- Revisa los logs del CI para vulnerabilidades específicas
- Busca en npm/GitHub si hay actualizaciones disponibles
- Considera alternativas para dependencias problemáticas