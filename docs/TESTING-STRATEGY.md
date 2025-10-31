# Testing Strategy & Execution Record

Document updated: 2025-10-31

This document centralises every automated and manual test that we run across the STI App stack. It complements the existing CI/CD and architecture docs with a testing-first view so you can trace **what** is tested, **how**, **where it runs**, and **how to reproduce it locally**.

---

## 1. Test Portfolio Summary

| # | Scope | Goal | Tooling | Trigger | Canonical Command |
|---|-------|------|---------|---------|-------------------|
| 1 | Backend unit | Validate NestJS services/controllers in isolation | Jest | `npm run test:cov` (CI + local) | `cd backend && npm run test:cov` |
| 2 | Backend e2e | Exercise HTTP endpoints + TypeORM + PostgreSQL | Jest + Supertest + Docker service | `npm run test:e2e` (CI + local) | `cd backend && npm run test:e2e` |
| 3 | Backend integration | Focused DB scenarios (custom jest-integration) | Jest + Supertest | Manual/adhoc | `cd backend && npm run test:integration` |
| 4 | Frontend unit | Component/service specs with code coverage | Karma + Jasmine + Headless Chrome | `npm run test:cov` (CI + local) | `cd frontend && npm run test:cov` |
| 5 | Linting (FE) | Template & TS static checks (relaxed rules documented) | ESLint + Angular ESLint | `npm run lint` (CI + local) | `cd frontend && npm run lint` |
| 6 | Linting (BE) | Enforce NestJS code style & detect smells | ESLint | `npm run lint` (CI + local) | `cd backend && npm run lint` |
| 7 | Security audit | Detect vulnerable npm packages (non-blocking) | `npm audit` | Automatically in CI, on demand local | `npm audit --audit-level high` |
| 8 | Docker build test | Ensure Dockerfiles keep building | Docker CLI | CI job `docker-build-test` | `docker build -t sti-backend-test backend/` |
| 9 | Full-stack smoke | Spin up API + Angular + Postgres & hit health checks | Custom bash/batch scripts, `curl` | CI and local scripts | `./scripts/test/test-integration.sh` |
| 10 | Manual API regression | Validate deployed backend against Render DB | Postman | Manual (documented below) | Collection `docs/postman/*.json` (Run manually) |

---

## 2. GitHub Actions Coverage

### 2.1 `test-backend`
- Spins up a PostgreSQL 16 service inside the job to mirror production schema.
- Installs backend deps with `npm ci` to guarantee lockfile fidelity.
- Runs `npm audit` in **report-only** mode (pipeline never breaks because of low/moderate issues but we log the output and attempt `npm audit fix`).
- Executes `npm run lint` to keep TypeScript and NestJS conventions.
- Executes `npm run test:e2e` using `test/jest-e2e.json` (boots Nest, hits endpoints via Supertest, inserts data on the temporary DB, and tears it down automatically).
- Executes `npm run test:cov` to collect unit coverage; pushes `coverage/lcov.info` to Codecov with the `backend` flag.

### 2.2 `test-frontend`
- Uses Node 20 with npm caching.
- Falls back to `npm install` if `npm ci` detects an out-of-sync lock file (the same heuristic we documented in CI-CD improvements).
- Runs `npm audit` (non-blocking) and reports results.
- Executes `npm run lint` (per policy it is allowed to emit warnings—job does not fail).
- Runs `npm run test:cov`; Karma + Jasmine run on Chrome Headless (`CI=true` ensures non-interactive mode). Coverage is uploaded to Codecov under the `frontend` flag.
- Builds the Angular SSR bundle with `npm run build` to detect compilation regressions earlier.

### 2.3 `docker-build-test`
- Builds backend and frontend Docker images in isolation.
- Smoke tests backend image by running `node --version` inside the container (future task: add real health check using `curl`).
- Surface-level safeguard to prevent Dockerfile drift.

### 2.4 `integration-tests`
- Waits for `test-backend` & `test-frontend` to pass before executing.
- Starts a PostgreSQL 16 service.
- Launches the Nest API in **development mode** (TypeScript source, no build) for faster feedback.
- Builds frontend bundle & serves it through `http-server` on port 4200.
- Performs basic observability (`ps`, `netstat`) and smoke tests via `curl` against `/health` and the root of the Angular app.
- Designed to catch cross-service regressions (CORS, env vars, DB connectivity) that individual jobs could miss.

---

## 3. Backend Testing Details

### 3.1 Unit Tests (`npm run test:cov`)
- Location: `backend/src/**/*.spec.ts`.
- Scope: services (business logic), controllers (HTTP layer) using Nest TestingModule with mocks.
- Coverage: Jest collects statements/branches via `coverage/`. Thresholds are reviewed manually in Codecov.
- Local run:
  ```bash
  cd backend
  npm install
  npm run test:cov
  ```

### 3.2 End-to-End Tests (`npm run test:e2e`)
- Config: `backend/test/jest-e2e.json`.
- Uses Supertest to hit the real HTTP server; bootstraps Nest with in-memory overrides and connects to PostgreSQL.
- Requires running DB. Locally you can reuse docker-compose (see README) or boot the container manually:
  ```bash
  docker compose up db -d   # or use the provided stack
  cd backend
  npm run test:e2e
  ```
  Environment defaults to `.env.test` (ignored in git) and uses the seeded schema.

### 3.3 Integration Tests (`npm run test:integration`)
- Config: `backend/test/jest-integration.json`.
- Focus: deeper DB flows (e.g., combined queries, relations) without spinning the HTTP layer.
- These are optional/regression tests; run them when touching TypeORM entities or migrations.
- Command:
  ```bash
  cd backend
  npm run test:integration
  ```

### 3.4 Security Audit (`npm audit`)
- Non-blocking in CI but part of the workflow—logs highlight outstanding vulnerabilities.
- Locally run `npm audit --audit-level high` and, if needed, use the automation scripts under `scripts/fix/`.

### 3.5 Manual API Validation
- We maintain Postman collections (see `docs/` folder) to verify the deployed backend in Render.
- Typical flow after a release: validate `/health`, user/order CRUD, and DB side-effects.
- Record findings in `docs/session-history.md` when running exploratory sessions.

---

## 4. Frontend Testing Details

### 4.1 Unit & Coverage (`npm run test:cov`)
- Specs live under `frontend/src/**/*.spec.ts`.
- Executes Karma with Chrome Headless; coverage reports go to `frontend/coverage/sti-cct/lcov.info`.
- Local run:
  ```bash
  cd frontend
  npm install
  npm run test:cov
  ```

### 4.2 Linting (`npm run lint`)
- ESLint runs with Angular rules plus the relaxed set documented in `CI-CD-IMPROVEMENTS-2025-10-24.md`.
- Emits warnings for temporary rule suppressions (`no-explicit-any`, selectors, etc.) but still flags real errors.

### 4.3 Build Verification (`npm run build`)
- Generates SSR artifacts under `dist/sti-cct/{browser,server}`.
- Render Static Site uses `dist/sti-cct/browser` as publish directory.
- Run locally when modifying Angular configuration or environment files.

### 4.4 Manual UX Smoke
- After deployment, we hit the Render static URL with `curl` + browser sanity check to ensure assets load.
- For local full-stack validation use `./scripts/test/test-integration.*` to boot backend & serve frontend simultaneously.

---

## 5. Full-stack Smoke Scripts

Scripts live under `scripts/test/` and mirror part of the integration job.

### Windows (`test-integration.bat`)
- Starts backend (`npm run start`) with test env vars.
- Builds frontend, serves it via `http-server`, waits for both ports.
- Performs curl-based smoke checks.

### Linux/macOS (`test-integration.sh`)
- Adds cleanup trap (`pkill`) to stop Node processes when script exits.
- Ideal for local End-to-End smoke before pushing.

> Tip: To point the smoke scripts to a **remote backend** (e.g., Render), override env vars before running `npm run build` or tweak `frontend/src/environments/environment*.ts` accordingly, then rebuild.

---

## 6. Reporting & Observability

- **Codecov**: Receives backend (`flags=backend`) and frontend (`flags=frontend`) coverage uploads on every CI run.
- **CI Logs**: Each job logs npm audit summaries, lint output, test results, and smoke checks—useful for traceability during incidents.
- **Docker**: Build logs live in the `docker-build-test` job; failures usually mean Dockerfile drift.

---

## 7. Known Gaps & Follow-up

1. Enhance `docker-build-test` to run `npm run test:integration` inside the container for stronger validation.
2. Add Lighthouse or Playwright regression to cover UI behaviour (tracked in README future improvements).
3. Document seed data/migrations for end-to-end tests (roadmap item).

---

## 8. Quick Reference Commands

```bash
# Backend
cd backend
npm run lint
npm run test:cov
npm run test:e2e
npm run test:integration

# Frontend
cd frontend
npm run lint
npm run test:cov
npm run build

# Full stack smoke
./scripts/test/test-integration.sh   # macOS/Linux
scripts\test\test-integration.bat   # Windows
```

For any questions or to update this matrix after adding new tests, mention it in the next CI/CD improvements log and append a new row to the table above.
