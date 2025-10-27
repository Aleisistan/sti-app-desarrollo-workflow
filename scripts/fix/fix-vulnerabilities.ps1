# Script PowerShell para manejar vulnerabilidades de seguridad
# Usage: .\fix-vulnerabilities.ps1 [backend|frontend|all]

param(
    [string]$Target = "all"
)

Write-Host "🔒 Security Vulnerability Management Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

function Fix-Backend {
    Write-Host "🔧 Fixing Backend vulnerabilities..." -ForegroundColor Yellow
    Set-Location backend
    
    Write-Host "📋 Current vulnerabilities:" -ForegroundColor Blue
    npm audit --audit-level moderate
    if ($LASTEXITCODE -ne 0) { Write-Host "Vulnerabilities found" -ForegroundColor Yellow }
    
    Write-Host "🔄 Attempting to fix non-breaking vulnerabilities..." -ForegroundColor Blue
    npm audit fix --audit-level moderate
    if ($LASTEXITCODE -ne 0) { Write-Host "Some fixes may require manual intervention" -ForegroundColor Yellow }
    
    Write-Host "📊 Checking remaining vulnerabilities..." -ForegroundColor Blue
    npm audit --audit-level moderate
    if ($LASTEXITCODE -ne 0) { Write-Host "Some vulnerabilities remain" -ForegroundColor Yellow }
    
    Write-Host "✅ Backend vulnerability fix attempt completed" -ForegroundColor Green
    Set-Location ..
}

function Fix-Frontend {
    Write-Host "🔧 Fixing Frontend vulnerabilities..." -ForegroundColor Yellow
    Set-Location frontend
    
    # Check if package.json and package-lock.json are in sync
    Write-Host "🔄 Checking package.json and package-lock.json sync..." -ForegroundColor Blue
    $npmCiResult = npm ci 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "📦 package.json and package-lock.json are out of sync. Updating..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ package-lock.json updated successfully" -ForegroundColor Green
        }
    }
    
    Write-Host "📋 Current vulnerabilities:" -ForegroundColor Blue
    npm audit --audit-level moderate
    if ($LASTEXITCODE -ne 0) { Write-Host "Vulnerabilities found" -ForegroundColor Yellow }
    
    Write-Host "🔄 Attempting to fix non-breaking vulnerabilities..." -ForegroundColor Blue
    npm audit fix --audit-level moderate
    if ($LASTEXITCODE -ne 0) { Write-Host "Some fixes may require manual intervention" -ForegroundColor Yellow }
    
    Write-Host "📊 Checking remaining vulnerabilities..." -ForegroundColor Blue
    npm audit --audit-level moderate
    if ($LASTEXITCODE -ne 0) { Write-Host "Some vulnerabilities remain" -ForegroundColor Yellow }
    
    Write-Host "✅ Frontend vulnerability fix attempt completed" -ForegroundColor Green
    Set-Location ..
}

switch ($Target.ToLower()) {
    "backend" { Fix-Backend }
    "frontend" { Fix-Frontend }
    "all" { 
        Fix-Backend
        Fix-Frontend
    }
    default {
        Write-Host "❌ Invalid target. Use: backend, frontend, or all" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🎉 Vulnerability management completed!" -ForegroundColor Green
Write-Host "💡 If critical vulnerabilities remain, consider:" -ForegroundColor Cyan
Write-Host "   - Updating to newer versions manually" -ForegroundColor White
Write-Host "   - Using 'npm audit fix --force' (⚠️  may introduce breaking changes)" -ForegroundColor White
Write-Host "   - Adding exceptions for false positives" -ForegroundColor White
