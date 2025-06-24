#!/bin/bash

# Development Run Script for Ruby Work Meter
# This script sets up the environment and runs both JSON server and Flutter app

echo "🚀 Starting Ruby Work Meter Development Environment..."

# Check if JSON server is already running
if curl -s http://localhost:3001/workmeter > /dev/null 2>&1; then
    echo "✅ JSON server is already running on port 3001"
else
    echo "📡 Starting JSON server on port 3001..."
    npm start &
    sleep 3
    
    # Check if server started successfully
    if curl -s http://localhost:3001/workmeter > /dev/null 2>&1; then
        echo "✅ JSON server started successfully"
    else
        echo "❌ Failed to start JSON server"
        exit 1
    fi
fi

# Set environment variables
echo "🔧 Setting up environment variables..."
export DEVELOPMENT=true
export API_URL=http://localhost:3001/workmeter

echo "📱 Starting Flutter app..."
echo "Environment: DEVELOPMENT=$DEVELOPMENT"
echo "API URL: $API_URL"
echo ""
echo "💡 Tips:"
echo "   - Use 'R' to hot restart the app"
echo "   - Use 'q' to quit"
echo "   - Dark mode toggle is available in the app bar"
echo ""

# Run Flutter app
flutter run 