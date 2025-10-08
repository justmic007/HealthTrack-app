# Integration Tests

Integration tests verify complete user workflows and critical app functionality in the HealthTrack mobile app.

## Test Structure

```
integration_test/
├── app_smoke_test.dart           # Basic app functionality
├── auth_flow_test.dart           # Authentication workflows  
├── navigation_flow_test.dart     # Navigation and routing
├── form_validation_test.dart     # Form validation flows
├── user_interface_test.dart      # UI components and styling
├── app_integration_test.dart     # Main test runner
└── README.md                     # This file
```

## Test Categories

### 1. Smoke Tests (5 tests)
**File**: `app_smoke_test.dart`
- App loads without crashing
- Login screen elements present
- Basic navigation functionality
- Form validation triggers
- Text input functionality

### 2. Authentication Flow Tests (4 tests)
**File**: `auth_flow_test.dart`
- Complete login workflow
- Login validation errors
- Navigation to registration
- Password visibility toggle

### 3. Navigation Flow Tests (4 tests)
**File**: `navigation_flow_test.dart`
- Main navigation between screens
- Patient registration flow
- Caregiver registration flow
- Lab registration flow
- Back navigation functionality

### 4. Form Validation Tests (4 tests)
**File**: `form_validation_test.dart`
- Patient registration form validation
- Caregiver registration form validation
- Form field interactions and input
- Dropdown selection functionality

### 5. User Interface Tests (6 tests)
**File**: `user_interface_test.dart`
- App theme and styling verification
- Responsive layout elements
- Icons and visual components
- Loading and state indicators
- Accessibility elements
- Error message display

## Running Integration Tests

### Prerequisites
1. **Device/Emulator**: Android emulator or iOS simulator must be running
2. **Backend API**: Optional - tests handle API failures gracefully
3. **Build**: App must compile successfully

### Quick Start
```bash
# Check available devices
flutter devices

# Run basic smoke tests
flutter test integration_test/app_smoke_test.dart -d <device-id>

# Run all integration tests
flutter test integration_test/ -d <device-id>
```

### Device-Specific Commands
```bash
# iOS Simulator
flutter test integration_test/app_smoke_test.dart -d "iPhone 14 Pro Max"

# Android Emulator  
flutter test integration_test/app_smoke_test.dart -d emulator-5554

# Specific device ID
flutter test integration_test/app_smoke_test.dart -d "48B1AEE1-C38E-49BC-AE00-3CA6340C5469"
```

### Individual Test Categories
```bash
# Smoke tests (recommended first)
flutter test integration_test/app_smoke_test.dart -d <device-id>

# Authentication flows
flutter test integration_test/auth_flow_test.dart -d <device-id>

# Navigation flows
flutter test integration_test/navigation_flow_test.dart -d <device-id>

# Form validation
flutter test integration_test/form_validation_test.dart -d <device-id>

# User interface
flutter test integration_test/user_interface_test.dart -d <device-id>
```

### Run Specific Tests
```bash
# Single test by name
flutter test integration_test/app_smoke_test.dart -d <device-id> --name "app loads successfully"

# With verbose output
flutter test integration_test/app_smoke_test.dart -d <device-id> --reporter=expanded
```

## Test Coverage

**Total Integration Tests**: 23 tests

### Critical User Flows Tested:
- ✅ **App Initialization** - App loads without crashing
- ✅ **User Registration** - All user types (patient, caregiver, lab)
- ✅ **Authentication** - Login, validation, error handling
- ✅ **Navigation** - Screen transitions, back navigation
- ✅ **Form Validation** - Input validation, error messages
- ✅ **UI Components** - Styling, layout, accessibility

### Key Features Verified:
- Complete registration workflows for all user types
- Form validation with proper error messages
- Navigation between all registration screens
- UI consistency and accessibility
- Loading states and error handling
- Password visibility toggles
- Dropdown selections and form interactions

## Backend Integration

### With Backend Running
When the HealthTrack API is running, tests can verify:
- Complete authentication flows
- API error handling
- Network request/response cycles
- Real data validation

```bash
# Start backend API
cd /path/to/healthtrack-api
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Without Backend
Tests are designed to work gracefully without backend:
- UI flows and validation work normally
- API calls fail gracefully with proper error handling
- Form validation and navigation still testable
- Loading states and error messages verified

## Test Dependencies

Integration tests require:
- `integration_test` - Flutter integration testing framework
- `flutter_test` - Core testing utilities
- Running emulator/simulator
- Main app entry point (`main.dart`)

## Performance Considerations

Integration tests are slower than unit/widget tests because they:
- Launch the full app with all dependencies
- Interact with real UI components and animations
- Include network timeouts and state management
- Test complete user workflows end-to-end

**Expected runtime**: 
- Single test: 30-60 seconds
- Full suite: 5-10 minutes

## Debugging Integration Tests

### Common Issues

1. **Device Not Found**
   ```bash
   # Check available devices
   flutter devices
   
   # Use specific device ID
   flutter test integration_test/app_smoke_test.dart -d "device-id-here"
   ```

2. **App Doesn't Load**
   - Ensure app compiles: `flutter build ios` or `flutter build apk`
   - Check for build errors in dependencies
   - Verify emulator/simulator is fully booted

3. **Widget Not Found**
   - App routing may redirect to different screen
   - Authentication state affects initial screen
   - Use longer wait times: `pumpAndSettle(Duration(seconds: 10))`

4. **Network Timeouts**
   - Tests handle API failures gracefully
   - Check backend API status if needed
   - Verify device network connectivity

### Debug Commands
```bash
# Verbose output
flutter test integration_test/app_smoke_test.dart -d <device-id> --verbose

# Single test with debug info
flutter test integration_test/app_smoke_test.dart -d <device-id> --name "app loads successfully" --reporter=expanded

# Check Flutter doctor
flutter doctor -v
```

### Test Development Tips

1. **Start Simple**: Begin with smoke tests before complex flows
2. **Wait for Loading**: Use `pumpAndSettle(Duration(seconds: 5-10))`
3. **Handle Routing**: App may redirect based on auth state
4. **Graceful Failures**: Tests should handle API failures
5. **Device Specific**: Test on both iOS and Android

## Integration with Other Tests

Integration tests complement unit and widget tests:
- **Unit Tests (116)**: Business logic and data models
- **Widget Tests (37)**: UI components in isolation  
- **Integration Tests (23)**: Complete user workflows
- **Total: 176 tests** providing comprehensive coverage

### Test Pyramid
```
Integration Tests (23) - End-to-end user workflows
Widget Tests (37)      - UI components and interactions  
Unit Tests (116)       - Business logic and data models
```

Integration tests verify that unit-tested logic and widget-tested components work together in real user scenarios with full app context.

## Continuous Integration

For CI/CD pipelines:
```bash
# Headless testing (when available)
flutter test integration_test/ --device-id=test

# With test reports
flutter test integration_test/ --reporter=json > integration_test_results.json
```

**Note**: Integration tests typically require physical devices or emulators, making them more suitable for local development and staging environments rather than every CI build.