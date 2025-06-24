#!/bin/bash

# Environment Setup Script for Ruby Work Meter
# Usage: ./scripts/setup_env.sh [development|production]

set_development_env() {
    echo "Setting up DEVELOPMENT environment..."
    export DEVELOPMENT=true
    export API_URL="http://localhost:3001/workmeter"
    echo "Environment variables set for DEVELOPMENT mode"
    echo "DEVELOPMENT=$DEVELOPMENT"
    echo "API_URL=$API_URL"
    echo ""
    echo "To run the app: flutter run"
    echo "To start local JSON server: json-server --watch db.json --port 3001"
}

set_production_env() {
    echo "Setting up PRODUCTION environment..."
    export DEVELOPMENT=false
    export API_URL="http://workmeter.herokuapp.com/services/c/"
    echo "Environment variables set for PRODUCTION mode"
    echo "DEVELOPMENT=$DEVELOPMENT"
    echo "API_URL=$API_URL"
    echo ""
    echo "To run the app: flutter run"
    echo "Note: API key will be required for authentication"
}

show_help() {
    echo "Ruby Work Meter Environment Setup"
    echo ""
    echo "Usage: $0 [development|production]"
    echo ""
    echo "Options:"
    echo "  development  - Set up development environment (bypasses auth, uses local server)"
    echo "  production   - Set up production environment (requires API key)"
    echo "  help         - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 development"
    echo "  $0 production"
    echo ""
    echo "After running this script, you can start the app with: flutter run"
}

# Main script logic
case "${1:-help}" in
    "development"|"dev")
        set_development_env
        ;;
    "production"|"prod")
        set_production_env
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Error: Unknown option '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac 