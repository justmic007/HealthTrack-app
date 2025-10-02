# HealthTrack

A production-grade health tracking mobile application built with Flutter.

## Project Structure

```
lib/
├── src/
│   ├── data/      # Repositories, data sources, API clients
│   ├── models/    # Data models and entities
│   ├── providers/ # State management (BLoC, Riverpod, etc.)
│   ├── screens/   # UI screens and pages
│   ├── utils/     # Utility functions and helpers
│   └── widgets/   # Reusable UI components
├── app.dart       # Main app configuration
└── main.dart      # Entry point
```

## Getting Started

### Prerequisites
1. Install dependencies: `flutter pub get`
2. Verify Flutter setup: `flutter doctor`

### Running the App

#### 🤖 Android Only

**Step 1: Start Android Emulator**
```bash
# List available emulators
flutter emulators

# Launch Android emulator (choose one)
flutter emulators --launch Pixel_6
# OR
flutter emulators --launch Pixel_4_XL
```

**Step 2: Run on Android**
```bash
# Run on Android (auto-detects emulator)
flutter run -d android

# OR use specific device ID
flutter run -d emulator-5554
```

---

#### 🍎 iOS Only

**Step 1: Start iOS Simulator**
```bash
# Launch iOS Simulator
open -a Simulator
flutter run -d "iPhone 14 Pro Max"

# OR let Flutter handle it automatically
flutter run -d ios
```

**Step 2: Run on iOS**
```bash
# Run on iOS Simulator
flutter run -d ios

# OR use specific device ID
flutter run -d "iPhone 14 Pro Max"
```

---

#### 🚀 Both Platforms Simultaneously

**Step 1: Stop Any Running Emulators**
```bash
# Stop Flutter processes
pkill -f "flutter run"

# Stop Android emulator
adb emu kill

# Stop iOS Simulator
xcrun simctl shutdown all
```

**Step 2: Start Both Emulators**
```bash
# Start Android emulator in background
flutter emulators --launch Pixel_6 &

# Start iOS Simulator
open -a Simulator
```

**Step 3: Verify Devices and Run**
```bash
# Check available devices
flutter devices

# Run on all devices simultaneously
flutter run -d all
```

**Alternative: Run on Specific Devices**
```bash
# Terminal 1:
flutter run -d ios

# Terminal 2 (new terminal window):
flutter run -d android
```

---

### 🔍 Troubleshooting Device Detection

**No devices found?**
```bash
# Check device status
flutter devices

# For Android: Ensure emulator is fully booted
# For iOS: Ensure Simulator is open and device is selected
```

**Multiple devices available?**
```bash
# List all devices with IDs
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Platforms

- ✅ iOS
- ✅ Android

## Android Build Troubleshooting

### 🚨 Common Error: Java-Gradle Version Incompatibility

#### Symptoms
```
FAILURE: Build failed with an exception.

What went wrong?
Could not open cp_settings generic class cache for settings file

BUG! exception in phase 'semantic analysis' in source unit 'BuildScript' 
Unsupported class file major version 65
```

#### Root Cause
Java 21 (major version 65) being used with an older Gradle version that doesn't support it.

---

## 🛠️ Step-by-Step Solution

### 1. Verify and Set Java Environment
```bash
# Check installed Java versions
/usr/libexec/java_home -V

# Set JAVA_HOME to Java 17 (recommended)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
echo "JAVA_HOME set to: $JAVA_HOME"

# Verify Java version
java -version
```
**Recommended:** Java 17 (OpenJDK)  
**Avoid:** Java 21 unless using latest Gradle versions


### 2. Fix File Ownership Issues
*(If you accidentally used sudo with gradle commands)*
```bash
# Fix project ownership
sudo chown -R $(whoami) /path/to/your/flutter/project/

# Fix Gradle cache ownership  
sudo chown -R $(whoami) ~/.gradle/

# Fix Flutter SDK ownership
sudo chown -R $(whoami) /path/to/flutter/sdk/
```


### 3. Update Gradle Configuration
**File:** `android/gradle/wrapper/gradle-wrapper.properties`
```properties
# Update distribution URL
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
```

**File:** `android/build.gradle`
```gradle
buildscript {
    ext.kotlin_version = '1.8.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.2.0"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

### 4. Update App-Level Build Configuration
**File:** `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
```

### 5. Clean and Rebuild
```bash
# Complete cleanup
flutter clean
rm -rf ~/.gradle/caches/
rm -rf android/.gradle/
rm -rf build/

# Refresh dependencies
flutter pub get

# Rebuild
flutter run -d android
```

---

## 🔧 Android Studio Configuration

1. Open **Android Studio** → **Preferences**
2. Navigate to **Build, Execution, Deployment** → **Build Tools** → **Gradle**
3. Ensure **Gradle JVM** is set to **Java 17** (not "Use embedded JDK")

---

## 🚦 Common Scenarios & Quick Fixes

### Permission Denied Errors
```bash
# Fix ownership issues
sudo chown -R $(whoami) ~/.gradle/

# Remove lock files
find ~/.gradle -name "*.lock" -delete
pkill -f gradle
```

### Missing Gradle Files
```bash 
# Regenerate Android files
flutter create --platforms=android .
```

### Multiple Java Versions
```bash
# Remove conflicting Java versions
brew uninstall openjdk@21

# Set default to Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

---

## 📱 Running on Android

### Start Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel_6
```

### Run App
```bash
# Run on Android
flutter run -d android

# Or use specific device ID
flutter run -d emulator-5554
```

---

## ✅ Prevention Best Practices

1. **Never use sudo** with Flutter/Gradle commands
2. **Maintain version compatibility:**
   - Java 17 → Gradle 8.4 → Android Gradle Plugin 8.2.0
3. **Regularly update** Flutter and dependencies
4. **Use Android Studio's built-in terminal** to avoid PATH issues

---

## 🧪 Verification Checklist

- ✅ Java 17 is installed and set as default
- ✅ Gradle 8.4+ in wrapper properties
- ✅ Android Gradle Plugin 8.2.0+
- ✅ compileSdkVersion 34
- ✅ JavaVersion.VERSION_17 in compileOptions
- ✅ All files owned by user (not root)
- ✅ No permission errors in ~/.gradle/

---

## 🎯 Final Test Commands

```bash
# Verify environment setup
flutter doctor -v
./android/gradlew --version
java -version

# Test build
flutter build apk --debug
```

#### Recommended Versions
| Component | Version |
|-----------|----------|
| Java | 17 (OpenJDK) |
| Gradle | 8.4+ |
| Android Gradle Plugin | 8.2.0+ |
| compileSdkVersion | 34 |

---

## 📝 Additional Notes

- This guide addresses Java-Gradle version compatibility issues
- The error "Unsupported class file major version 65" indicates Java 21 incompatibility
- Always ensure version compatibility between Java, Gradle, and Android Gradle Plugin
- Keep your Flutter SDK updated: `flutter upgrade`

---

## 🔗 Backend API Integration

### Prerequisites
1. **Backend API running** - HealthTrack FastAPI server must be accessible
2. **Network connectivity** - Mobile apps need to reach the API server

### 🚀 Quick Setup

#### Step 1: Start Backend API
```bash
cd /path/to/healthtrack-api

# For mobile app development - allow external connections
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Step 2: Get Your Mac's IP Address
```bash
# Find your local IP address
ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1
# Example output: inet 192.168.100.81
```

#### Step 3: Mobile App Configuration
The mobile app **automatically detects your local IP** for iOS simulator:
- **Android Emulator**: `http://10.0.2.2:8000/api/v1` (universal)
- **iOS Simulator**: Dynamically detects your Mac's IP (works for all testers)

### 👥 Team Testing Setup

#### For Other Testers
**Android Testing** ✅
- Works immediately - `10.0.2.2` is universal for all Android emulators
- No configuration needed

**iOS Testing** ✅
- App automatically detects each tester's Mac IP address
- No manual configuration required
- Each tester just needs to:
  1. Run their own backend: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
  2. Run iOS simulator: `flutter run -d ios`

#### Alternative: Manual IP Configuration
If automatic detection fails, testers can manually set their IP:
```dart
// In lib/src/data/api_client.dart - temporarily for testing
return 'http://TESTER_IP:8000/api/v1';  // Replace with tester's actual IP
```

### 🔧 Network Configuration Details

#### Why Different URLs?
- **Android Emulator** runs in a VM with special networking
  - `10.0.2.2` is the emulator's gateway to host machine
  - `localhost` from emulator = emulator itself, not your Mac

- **iOS Simulator** runs natively on macOS
  - Can access your Mac's network interfaces directly
  - Uses your actual IP address to reach the API

#### Backend Server Configuration
```bash
# ❌ This only accepts localhost connections
uvicorn app.main:app --reload

# ✅ This accepts connections from mobile apps
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 🧪 Testing API Connectivity

#### Verify API is Accessible
```bash
# Test from your Mac's browser
open http://YOUR_IP:8000/docs
# Example: http://192.168.100.81:8000/docs
```

#### Test Mobile App Connection
1. **Start backend**: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
2. **Run mobile apps**: `flutter run -d all`
3. **Test login** on both Android and iOS

### 🚨 Common Issues & Solutions

#### "Connection Refused" Error
**Symptoms:**
```
ClientException with SocketException: Connection refused
address = localhost, port = 8000
```

**Solutions:**
1. **Check backend is running** with external access:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Verify IP address** in mobile app matches your Mac's IP

3. **Check firewall settings** - Ensure port 8000 is not blocked

#### "Operation Timed Out" Error
**Symptoms:**
```
SocketException: Operation timed out
address = 10.0.2.2, port = 8000
```

**Solutions:**
1. **Use correct platform URL**:
   - Android: `10.0.2.2:8000`
   - iOS: `YOUR_ACTUAL_IP:8000`

2. **Ensure backend accepts external connections**

#### "Null is not a subtype of String" Error
**Cause:** API response parsing issues

**Solution:** Check API response format matches mobile app models

### 📱 Platform-Specific Configuration

#### Android Emulator
```dart
// lib/src/data/api_client.dart
if (Platform.isAndroid) {
  return 'http://10.0.2.2:8000/api/v1';  // Android emulator
}
```

#### iOS Simulator
```dart
// lib/src/data/api_client.dart
if (Platform.isIOS) {
  // Dynamically detects each tester's Mac IP
  final localIP = await NetworkUtils.getLocalIP();
  return 'http://$localIP:8000/api/v1';
}
```

### 🔒 Security Considerations

#### Development Environment
- ✅ **`--host 0.0.0.0`** is safe for local development
- ✅ **Local network access** only (192.168.x.x)
- ✅ **No internet exposure** unless port forwarded

#### Production Environment
- 🚨 **Never use `--host 0.0.0.0`** in production
- 🚨 **Use proper SSL/TLS** certificates
- 🚨 **Configure firewall rules** appropriately

### 📋 Development Workflow

#### Daily Development Setup
```bash
# Terminal 1: Start backend API
cd /path/to/healthtrack-api
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Terminal 2: Run Android app
cd /path/to/healthtrack-mobile
flutter run -d emulator-5554

# Terminal 3: Run iOS app
cd /path/to/healthtrack-mobile
flutter run -d ios
```

#### API Documentation Access
- **Swagger UI**: `http://YOUR_IP:8000/docs`
- **ReDoc**: `http://YOUR_IP:8000/redoc`

### ✅ Development Integration Checklist

- ✅ Backend API running with `--host 0.0.0.0`
- ✅ Mobile app URLs configured for both platforms
- ✅ Network connectivity tested
- ✅ Authentication flow working
- ✅ API documentation accessible
- ✅ Both Android and iOS apps connecting successfully

---

## 🚀 Production Deployment

### 📱 App Store & Play Store Configuration

**The current development IPs (`10.0.2.2`, `192.168.100.81`) are ONLY for local development.** For production apps, you need a proper production API server.

#### Production API Requirements
1. **Public domain** - e.g., `https://api.healthtrack.com`
2. **SSL/TLS certificate** - HTTPS required for app stores
3. **Cloud hosting** - AWS, Google Cloud, Azure, etc.
4. **Production database** - Not local development DB

### 🔧 Mobile App Configuration

The app automatically detects production vs development:

```dart
// lib/src/data/api_client.dart
static String get baseUrl {
  if (_isProduction) {
    return 'https://api.healthtrack.com/api/v1';  // Production
  } else {
    // Development URLs (emulator/simulator)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      return 'http://192.168.100.81:8000/api/v1';
    }
  }
}
```

### 🌐 Backend Deployment Options

#### Option 1: AWS (Recommended)
```bash
# Deploy FastAPI to AWS Lambda + API Gateway
# Or AWS ECS/Fargate for containerized deployment
```

#### Option 2: Google Cloud
```bash
# Deploy to Google Cloud Run
gcloud run deploy healthtrack-api --source .
```

#### Option 3: Railway/Render (Simple)
```bash
# Connect GitHub repo to Railway/Render
# Automatic deployments on git push
```

#### Option 4: DigitalOcean App Platform
```bash
# Deploy directly from GitHub
# Built-in SSL certificates
```

### 📋 Production Deployment Checklist

#### Backend API
- ✅ **Domain purchased** - e.g., `healthtrack.com`
- ✅ **SSL certificate** - Let's Encrypt or cloud provider
- ✅ **Production database** - PostgreSQL on cloud
- ✅ **Environment variables** - Secure secrets management
- ✅ **API deployed** - Accessible at `https://api.healthtrack.com`
- ✅ **CORS configured** - Allow mobile app origins
- ✅ **Rate limiting** - Prevent API abuse
- ✅ **Monitoring** - Error tracking and logging

#### Mobile Apps
- ✅ **Production build** - `flutter build apk --release` / `flutter build ios --release`
- ✅ **API URL updated** - Points to production domain
- ✅ **App signing** - Release certificates configured
- ✅ **Store listings** - App Store Connect / Google Play Console
- ✅ **Privacy policy** - Required for health apps
- ✅ **Terms of service** - Legal requirements

### 🔒 Security for Production

#### API Security
```python
# healthtrack-api production settings
CORS_ORIGINS = ["https://healthtrack.com"]  # Not "*"
ALLOWED_HOSTS = ["api.healthtrack.com"]
DEBUG = False
SECURE_SSL_REDIRECT = True
```

#### Mobile App Security
- ✅ **Certificate pinning** - Prevent man-in-the-middle attacks
- ✅ **API key obfuscation** - Don't hardcode secrets
- ✅ **Biometric authentication** - For sensitive health data
- ✅ **Data encryption** - Local storage encryption

### 🚀 Build Commands for Production

#### Android (Play Store)
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release
```

#### iOS (App Store)
```bash
# Build for App Store
flutter build ios --release

# Archive in Xcode for submission
open ios/Runner.xcworkspace
```

### 📊 Production Monitoring

#### Backend Monitoring
- **API uptime** - Pingdom, UptimeRobot
- **Error tracking** - Sentry, Rollbar
- **Performance** - New Relic, DataDog
- **Database** - Connection pooling, query optimization

#### Mobile App Analytics
- **Crash reporting** - Firebase Crashlytics
- **User analytics** - Firebase Analytics, Mixpanel
- **Performance** - Firebase Performance Monitoring

### 💰 Estimated Production Costs

#### Monthly Costs (Estimated)
- **Domain**: $10-15/year
- **SSL Certificate**: Free (Let's Encrypt) or $50-100/year
- **Cloud hosting**: $20-100/month (depending on usage)
- **Database**: $20-50/month
- **Monitoring**: $0-50/month
- **App Store fees**: $99/year (Apple) + $25 one-time (Google)

### 🎯 Production Deployment Steps

1. **Purchase domain** - `healthtrack.com`
2. **Set up cloud hosting** - AWS, Google Cloud, etc.
3. **Deploy backend API** - With SSL certificate
4. **Update mobile app** - Point to production API
5. **Test thoroughly** - All features work with production API
6. **Build release versions** - Signed APK/IPA files
7. **Submit to stores** - App Store Connect & Google Play Console
8. **Monitor deployment** - Watch for errors and performance

### ⚠️ Important Notes

- **Never use development IPs in production**
- **Always use HTTPS for production APIs**
- **Test production builds thoroughly before submission**
- **Have rollback plan ready**
- **Monitor app performance post-launch**

---ecting successfully

---










