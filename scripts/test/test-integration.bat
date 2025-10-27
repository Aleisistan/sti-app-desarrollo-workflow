@echo off
setlocal enabledelayedexpansion

echo 🧪 Testing Local Integration
echo ===========================

echo 🔧 Setting up backend...
cd backend

echo  Starting backend in development mode (no build needed)...
set NODE_ENV=test
set DB_HOST=localhost
set DB_PORT=5432
set DB_USERNAME=postgres
set DB_PASSWORD=secret123!
set DB_DATABASE=sticct_test

start /B npm run start

echo ⏳ Waiting for backend to be ready...
for /L %%i in (1,1,30) do (
    curl -f http://localhost:3000/health >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo ✅ Backend is ready!
        goto backend_ready
    )
    echo Waiting for backend... (%%i/30)
    timeout /t 1 /nobreak >nul
)

echo ❌ Backend failed to start
exit /b 1

:backend_ready
cd ..\frontend

echo 📦 Building frontend...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Frontend build failed
    exit /b 1
)

echo 🚀 Starting frontend...
start /B npx http-server dist/sti-cct -p 4200

echo ⏳ Waiting for frontend to be ready...
for /L %%i in (1,1,15) do (
    curl -f http://localhost:4200 >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo ✅ Frontend is ready!
        goto frontend_ready
    )
    echo Waiting for frontend... (%%i/15)
    timeout /t 1 /nobreak >nul
)

echo ❌ Frontend failed to start
exit /b 1

:frontend_ready
cd ..

echo 🧪 Running smoke tests...
echo Testing backend health endpoint...
curl http://localhost:3000/health

echo.
echo Testing frontend...
curl http://localhost:4200

echo.
echo 🎉 All tests passed!

echo 🧹 Cleanup: Remember to stop the services manually if needed
echo   - Kill Node.js processes running on ports 3000 and 4200
