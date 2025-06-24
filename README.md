# Ruby Work Meter

A Flutter application for tracking work hours and leave management with environment-based configuration support.

## Features

- **Environment-based Configuration**: Supports both development and production modes
- **API Key Authentication**: Secure authentication for production use
- **Local Development Server**: JSON server support for development
- **Work Hour Tracking**: Real-time work hour monitoring
- **Leave Management**: Track casual, medical, and earned leaves
- **Attendance History**: View past attendance records
- **Dark/Light Theme**: User preference theme switching

## Environment Configuration

This app supports two modes of operation:

### Development Mode
- Bypasses API key validation
- Uses local JSON server or mock data
- Shows "DEVELOPMENT MODE" indicator
- Perfect for testing and development

### Production Mode
- Requires valid API keys
- Connects to production OrangeHRM API
- Enforces all authentication rules
- Secure production deployment

## Quick Start

### Prerequisites
- Flutter SDK (>=2.12.0)
- Dart SDK
- Node.js (for JSON server in development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ruby_work_meter
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Install JSON server (for development):
```bash
npm install
```

### Running the App

#### Development Mode
```bash
# Set up development environment
source scripts/setup_env.sh development

# Start JSON server (optional)
npm start

# Run the app
flutter run
```

#### Production Mode
```bash
# Set up production environment
source scripts/setup_env.sh production

# Run the app
flutter run
```

## Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `DEVELOPMENT` | boolean | false | Set to true for development mode |
| `API_URL` | string | varies | API endpoint URL |
| `API_KEY` | string | null | Production API key (optional) |

### Setting Environment Variables

#### Option 1: Using the Setup Script
```bash
# Development
./scripts/setup_env.sh development

# Production
./scripts/setup_env.sh production
```

#### Option 2: Manual Setup
```bash
# Development
export DEVELOPMENT=true
export API_URL=http://localhost:3000/api/

# Production
export DEVELOPMENT=false
export API_URL=http://workmeter.herokuapp.com/services/c/
```

#### Option 3: IDE Configuration
See `ENVIRONMENT_SETUP.md` for detailed IDE configuration instructions.

## Local JSON Server Setup

For development, you can use a local JSON server:

1. Start the server:
```bash
npm start
```

2. The server will be available at `http://localhost:3000`

3. Access endpoints:
   - `GET /workmeter` - Get work meter data
   - `GET /no_data` - Get no data response

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # App configuration
├── services/
│   ├── api_service.dart         # API service layer
│   ├── environment_config.dart  # Environment configuration
│   ├── mock_api_service.dart    # Mock data service
│   └── app_theme.dart           # Theme configuration
├── pages/
│   ├── login.dart               # Login page
│   ├── home_page.dart           # Main home page
│   └── ...                      # Other pages
├── widgets/
│   ├── common/                  # Common widgets
│   ├── profile/                 # Profile widgets
│   └── ...                      # Other widget categories
└── main.dart                    # App entry point
```

## API Integration

### Production API
The app integrates with OrangeHRM API for production use:
- Endpoint: `http://workmeter.herokuapp.com/services/c/{api_key}`
- Authentication: API key required
- Data format: JSON

### Development API
For development, the app supports:
- Local JSON server
- Mock data fallback
- No authentication required

## Configuration Files

- `db.json` - JSON server database
- `package.json` - Node.js dependencies and scripts
- `scripts/setup_env.sh` - Environment setup script
- `ENVIRONMENT_SETUP.md` - Detailed setup guide

## Troubleshooting

### Common Issues

1. **Environment variables not detected**
   - Restart your IDE/terminal
   - Check variable names (case-sensitive)
   - Verify variable values

2. **API connection issues**
   - Check if `API_URL` is correct
   - Verify network connectivity
   - Check if local JSON server is running

3. **Authentication failures**
   - Ensure `DEVELOPMENT` is set correctly
   - Check if API key is valid (production mode)
   - Verify API endpoint is accessible

### Debug Information

The app prints configuration information on startup. Check the console output for:
- Current environment (Development/Production)
- API URL being used
- Authentication requirements
- Any configuration errors

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in both development and production modes
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
- Check the `ENVIRONMENT_SETUP.md` file
- Review the troubleshooting section
- Open an issue on the repository
