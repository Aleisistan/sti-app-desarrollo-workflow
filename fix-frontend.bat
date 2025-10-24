@echo off
echo 🔧 Fixing Frontend Lock File Sync Issue...
echo ========================================

cd frontend

echo 📦 Syncing package.json and package-lock.json...
npm install

if %ERRORLEVEL% EQU 0 (
    echo ✅ Lock file synchronized successfully!
    echo 🔄 Now running vulnerability fixes...
    npm audit fix
    if %ERRORLEVEL% EQU 0 (
        echo ✅ Vulnerabilities fixed!
    ) else (
        echo ⚠️  Some vulnerabilities may require manual attention
    )
) else (
    echo ❌ Failed to sync lock file
    exit /b 1
)

cd ..
echo 🎉 Frontend fixes completed!