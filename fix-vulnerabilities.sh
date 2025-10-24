#!/bin/bash

# Script para manejar vulnerabilidades de seguridad de manera controlada
# Usage: ./fix-vulnerabilities.sh [backend|frontend|all]

set -e

echo "🔒 Security Vulnerability Management Script"
echo "=========================================="

TARGET=${1:-all}

fix_backend() {
    echo "🔧 Fixing Backend vulnerabilities..."
    cd backend
    
    echo "📋 Current vulnerabilities:"
    npm audit --audit-level moderate || true
    
    echo "🔄 Attempting to fix non-breaking vulnerabilities..."
    npm audit fix --audit-level moderate || true
    
    echo "📊 Checking remaining vulnerabilities..."
    npm audit --audit-level moderate || true
    
    echo "✅ Backend vulnerability fix attempt completed"
    cd ..
}

fix_frontend() {
    echo "🔧 Fixing Frontend vulnerabilities..."
    cd frontend
    
    echo "📋 Current vulnerabilities:"
    npm audit --audit-level moderate || true
    
    echo "🔄 Attempting to fix non-breaking vulnerabilities..."
    npm audit fix --audit-level moderate || true
    
    echo "📊 Checking remaining vulnerabilities..."
    npm audit --audit-level moderate || true
    
    echo "✅ Frontend vulnerability fix attempt completed"
    cd ..
}

case $TARGET in
    backend)
        fix_backend
        ;;
    frontend)
        fix_frontend
        ;;
    all)
        fix_backend
        fix_frontend
        ;;
    *)
        echo "❌ Invalid target. Use: backend, frontend, or all"
        exit 1
        ;;
esac

echo ""
echo "🎉 Vulnerability management completed!"
echo "💡 If critical vulnerabilities remain, consider:"
echo "   - Updating to newer versions manually"
echo "   - Using 'npm audit fix --force' (⚠️  may introduce breaking changes)"
echo "   - Adding exceptions for false positives"