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

**Step 1: Start Both Emulators**
```bash
# Start iOS Simulator
open -a Simulator

# Start Android Emulator
flutter emulators --launch Pixel_6

# Wait for both to fully load (30-60 seconds)
```

**Step 2: Check Available Devices**
```bash
flutter devices
```
You should see both iOS and Android devices listed.

**Step 3: Run on Both**
```bash
# Option 1: Run on all devices
flutter run -d all

# Option 2: Run on specific devices in separate terminals
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

## 📝 Notes

- This guide addresses Java-Gradle version compatibility issues
- The error "Unsupported class file major version 65" indicates Java 21 incompatibility
- Always ensure version compatibility between Java, Gradle, and Android Gradle Plugin
- Keep your Flutter SDK updated: `flutter upgrade`










