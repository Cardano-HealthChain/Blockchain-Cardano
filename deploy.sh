#!/bin/bash
set -e

echo "🚀 Starting HealthChain MVP Deployment..."

# 1. Build Smart Contracts
echo "📦 Building Aiken Smart Contracts..."
aiken build
# Ensure plutus.json exists
if [ ! -f plutus.json ]; then
    echo "❌ plutus.json not found! Build failed."
    exit 1
fi

echo "✅ Contracts built."

# 2. Setup Backend
echo "🛠 Setting up Backend API..."
cd api

# Install dependencies if node_modules missing
if [ ! -d "node_modules" ]; then
    echo "📦 Installing Node dependencies..."
    npm install
fi

# Build TypeScript
echo "🔨 Building API..."
npm run build

echo "✅ Backend built."

# 3. Copy artifacts
echo "📂 Copying contract artifacts to backend..."
mkdir -p dist/assets
cp ../plutus.json dist/assets/

echo "🎉 Deployment Ready! Run 'cd api && npm start' to launch the service."
