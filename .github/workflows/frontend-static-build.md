++ new file
1. Configurar Render Static Site con Angular
- **Repository**: Aleisistan/sti-app-desarrollo-workflow (branch `main`)
- **Root Directory**: `frontend` (Render → Advanced → Root Directory)
- **Build Command**: `npm install && npm run build`
- **Publish Directory**: `dist/sti-cct/browser`

2. Variables de entorno (si aplica)
- `NG_APP_API_URL=https://<backend>.onrender.com`

3. Redirect rule (SPA)
- Source `/*`
- Destination `/index.html`
- Type `Rewrite`