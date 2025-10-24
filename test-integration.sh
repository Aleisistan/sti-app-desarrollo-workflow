#!/bin/bash

# Script para probar la integración localmente
# Usage: ./test-integration.sh

set -e

echo "🧪 Testing Local Integration"
echo "==========================="

# Función para cleanup
cleanup() {
    echo "🧹 Cleaning up..."
    pkill -f "node.*dist/main" || true
    pkill -f "http-server" || true
    sleep 2
}

# Cleanup en caso de error
trap cleanup EXIT

echo "🔧 Setting up backend..."
cd backend

# Start backend in development mode (no build needed)
echo "🚀 Starting backend in development mode..."
NODE_ENV=test \
DB_HOST=localhost \
DB_PORT=5432 \
DB_USERNAME=postgres \
DB_PASSWORD=secret123! \
DB_DATABASE=sticct_test \
npm run start &

# Wait for backend
echo "⏳ Waiting for backend to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        echo "✅ Backend is ready!"
        break
    fi
    echo "Waiting for backend... ($i/30)"
    sleep 1
done

cd ../frontend

# Build and start frontend
echo "📦 Building frontend..."
npm run build

echo "🚀 Starting frontend..."
npx http-server dist/sti-cct -p 4200 &

# Wait for frontend
echo "⏳ Waiting for frontend to be ready..."
for i in {1..15}; do
    if curl -f http://localhost:4200 > /dev/null 2>&1; then
        echo "✅ Frontend is ready!"
        break
    fi
    echo "Waiting for frontend... ($i/15)"
    sleep 1
done

cd ..

echo "🧪 Running smoke tests..."
echo "Testing backend health endpoint..."
curl -v http://localhost:3000/health

echo ""
echo "Testing frontend..."
curl -v http://localhost:4200

echo ""
echo "🎉 All tests passed!"

# Cleanup will be called automatically due to trap