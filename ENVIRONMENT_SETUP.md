# Environment Setup Guide

This Flutter app supports both development and production environments through environment variables. The app automatically detects the environment and configures itself accordingly.

## Environment Variables

### Development Mode
When `DEVELOPMENT=true`, the app runs in development mode with the following behavior:
- Bypasses API key validation
- Uses local JSON server or mock data
- Shows "DEVELOPMENT MODE" indicator
- Allows empty API keys for testing

### Production Mode
When `DEVELOPMENT=false` or not set, the app runs in production mode:
- Requires valid API keys
- Connects to the production OrangeHRM API
- Enforces authentication

## Setting Environment Variables

### Option 1: System Environment Variables (Recommended)

Set these environment variables in your system:

```bash
# For Development
export DEVELOPMENT=true
export API_URL=http://localhost:3001/api/

# For Production
export DEVELOPMENT=false
export API_URL=http://workmeter.herokuapp.com/services/c/
export API_KEY=your_production_api_key_here
```

### Option 2: Flutter Run with Environment Variables

```bash
# Development mode
DEVELOPMENT=true API_URL=http://localhost:3001/api/ flutter run

# Production mode
DEVELOPMENT=false API_URL=http://workmeter.herokuapp.com/services/c/ flutter run
```

### Option 3: IDE Configuration

#### VS Code
Add to your `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "env": {
        "DEVELOPMENT": "true",
        "API_URL": "http://localhost:3001/api/"
      }
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "env": {
        "DEVELOPMENT": "false",
        "API_URL": "http://workmeter.herokuapp.com/services/c/"
      }
    }
  ]
}
```

#### Android Studio / IntelliJ
1. Go to Run → Edit Configurations
2. Add environment variables in the "Environment variables" field:
   ```
   DEVELOPMENT=true;API_URL=http://localhost:3001/api/
   ```

## Environment Variable Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `DEVELOPMENT` | boolean | false | Set to true for development mode |
| `API_URL` | string | varies | API endpoint URL |
| `API_KEY` | string | null | Production API key (optional) |

### Default Values

- **Development Mode**: `API_URL` defaults to `http://localhost:3001/api/`
- **Production Mode**: `API_URL` defaults to `http://workmeter.herokuapp.com/services/c/`

## Local JSON Server Setup (Development)

If you want to use a local JSON server for development:

1. Install json-server:
```bash
npm install -g json-server
```

2. Create a `db.json` file:
```json
{
  "workmeter": {
    "workedTime": "08:30",
    "workedAsInt": "0830",
    "emp_key": "dev_user_123",
    "work_hour": "08",
    "week_hour": "40",
    "updated_at": "2024-01-15T10:30:00Z",
    "week_minute": "00",
    "work_minute": "30",
    "leave_status": "CL-2,ML-3,EL-5",
    "emp_name": "Development User",
    "attendance": [
      {
        "date": "2024-01-15",
        "in_time": "09:00",
        "out_time": "17:30",
        "status": "present"
      }
    ],
    "cl": "2",
    "ml": "3",
    "el": "5",
    "in_out": "IN"
  }
}
```

3. Start the server:
```bash
json-server --watch db.json --port 3001
```

4. Set environment variables:
```bash
export DEVELOPMENT=true
export API_URL=http://localhost:3001/workmeter
```

## Testing Different Environments

### Development Testing
```bash
DEVELOPMENT=true flutter run
```
- App will show "DEVELOPMENT MODE" indicator
- Any key (or empty key) will work for login
- Uses mock data or local JSON server

### Production Testing
```bash
DEVELOPMENT=false flutter run
```
- App requires valid API key
- Connects to production OrangeHRM API
- Enforces all authentication rules

## Troubleshooting

### Common Issues

1. **Environment variables not detected**
   - Restart your IDE/terminal after setting variables
   - Check variable names (case-sensitive)
   - Verify variable values

2. **API connection issues**
   - Check if `API_URL` is correct
   - Verify network connectivity
   - Check if local JSON server is running (development mode)

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

## Security Notes

- Never commit API keys to version control
- Use environment variables for sensitive data
- In production, ensure API keys are properly secured
- Development mode should only be used for testing 