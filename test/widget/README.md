# Widget Tests

Widget tests verify UI components and user interactions in the HealthTrack mobile app.

## Test Structure

```
test/widget/
├── widgets/           # Custom widget tests
├── screens/           # Screen widget tests  
├── common/            # Common UI component tests
└── README.md          # This file
```

## Test Categories

### 1. Widget Tests (6 tests)
**File**: `widgets/exact_alarm_permission_dialog_test.dart`
- Dialog display and content validation
- Button functionality and navigation
- Text styling and layout verification

### 2. Screen Tests (20 tests)
**Files**: 
- `screens/login_screen_simple_test.dart` (9 tests)
- `screens/home_screen_simple_test.dart` (11 tests)

**Login Screen Tests**:
- Form field validation (email, password)
- Password visibility toggle
- Loading states and error messages
- UI styling and layout verification

**Home Screen Tests**:
- App bar and navigation elements
- User-specific content (patient, caregiver)
- Dashboard sections (health snapshot, test results, reminders)
- Floating action buttons and user interface

### 3. Common UI Tests (11 tests)
**File**: `common/form_widgets_test.dart`
- TextFormField validation and styling
- Button states and interactions
- Card layouts and tap handling
- ListTile content and navigation
- FloatingActionButton functionality

## Running Widget Tests

### All Widget Tests
```bash
flutter test test/widget --reporter=expanded
```

### Specific Categories
```bash
# Widget components only
flutter test test/widget/widgets --reporter=expanded

# Screen tests only  
flutter test test/widget/screens --reporter=expanded

# Common UI components only
flutter test test/widget/common --reporter=expanded
```

### Individual Test Files
```bash
# Login screen tests
flutter test test/widget/screens/login_screen_test.dart -v

# Home screen tests
flutter test test/widget/screens/home_screen_test.dart -v

# Dialog widget tests
flutter test test/widget/widgets/exact_alarm_permission_dialog_test.dart -v
```

## Test Coverage

**Total Widget Tests**: 37 tests

### Coverage Areas:
- ✅ **Authentication UI** - Login form validation, error handling
- ✅ **Dashboard Components** - Health snapshots, test results, reminders
- ✅ **Navigation Elements** - App bars, menus, floating action buttons
- ✅ **Form Components** - Text fields, buttons, validation
- ✅ **User Interactions** - Taps, form submission, navigation
- ✅ **State Management** - Loading states, error messages, user types
- ✅ **Responsive Design** - Layout verification, text styling

### Key Features Tested:
- Form validation and error display
- User type-specific UI elements
- Interactive components (buttons, cards, lists)
- Navigation and routing behavior
- Loading and error states
- Accessibility and styling

## Test Dependencies

Widget tests use these testing packages:
- `flutter_test` - Core Flutter testing framework
- `mockito` - Mocking for providers and services
- `provider` - State management testing

## Best Practices

1. **Isolated Testing** - Each widget test runs independently
2. **Mock Dependencies** - Use mocks for providers and external services
3. **User Interaction Focus** - Test from user perspective
4. **Accessibility** - Verify text, icons, and navigation elements
5. **State Verification** - Test different UI states (loading, error, success)

## Integration with Unit Tests

Widget tests complement unit tests by:
- **Unit Tests**: Test business logic and data models
- **Widget Tests**: Test UI components and user interactions
- **Integration Tests**: Test complete user workflows (coming next)

Widget tests ensure the UI correctly displays data from unit-tested models and services.