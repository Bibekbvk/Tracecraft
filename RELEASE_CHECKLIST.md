# TraceCraft — Google Play Store Release & Production Checklist

This document provides a step-by-step guide for building, signing, and publishing **TraceCraft** (AR Photo Tracing & Camera Lucida Drawing Assistant) to the Google Play Store.

---

## 1. Declared Android Permissions & Hardware Features

Verify that the following permissions and features are properly declared in `android/app/src/main/AndroidManifest.xml`:

| Permission / Feature | Purpose | Required? |
| :--- | :--- | :--- |
| `android.permission.CAMERA` | Live Camera Lucida preview for physical paper tracing | **Yes** |
| `android.permission.INTERNET` | Pexels/Pixabay image search, Firebase Cloud Firestore & Storage, AdMob | **Yes** |
| `android.permission.WAKE_LOCK` | Keeps phone display awake while tracing on paper (via `wakelock_plus`) | **Yes** |
| `android.permission.READ_MEDIA_IMAGES` | Selecting local reference photos or artwork for upload (Android 13+) | **Yes** |
| `android.permission.READ_EXTERNAL_STORAGE` | Backward compatibility for Android 12 and below | **Yes** (`maxSdkVersion=32`) |
| `android.hardware.camera` | Autofocus & camera hardware detection | Optional (`required=false`) |

---

## 2. Google Play Data Safety & Privacy Policy

Google Play requires a public Privacy Policy URL and completed Data Safety declaration:

### A. Camera Privacy
- **Declaration**: The camera feed is processed **strictly in real-time on-device** to render the Camera Lucida optical overlay.
- **Data Sharing**: Live camera feed frames are **never transmitted, stored, or shared** on remote servers.
- **Artwork Uploads**: Only when a user explicitly taps "Share Artwork" in the Community Showcase is their selected photo uploaded to Firebase Storage.

### B. Advertising & Analytics
- **AdMob**: Disclose the use of Google Mobile Ads (AdMob Advertising ID / Device Identifiers for personalized/non-personalized ad delivery).
- **Firebase Auth & Firestore**: Disclose anonymous user IDs stored to associate likes, star ratings, and community showcase submissions.

---

## 3. Keystore Generation & Release Signing

### Step 1: Generate Release Keystore
Run the following command in PowerShell / Terminal (replace with your secure password):

```powershell
keytool -genkey -v -keystore "C:\Users\Asus\upload-keystore.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Configure `android/key.properties`
Create a file at `android/key.properties` (never commit this file to public git):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:\\Users\\Asus\\upload-keystore.jks
```

### Step 3: Update `android/app/build.gradle`
Ensure `signingConfigs` is configured for release:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 4. ProGuard / R8 Rules for Production Minification

Create `android/app/proguard-rules.pro` to ensure Hive, Camera, and Firebase are not stripped during tree-shaking:

```proguard
# Hive TypeAdapters
-keep class io.flutter.plugins.** { *; }
-keep class trace_craft.models.** { *; }
-keepclassmembers class * extends io.flutter.plugin.common.StandardMessageCodec { *; }

# Google Mobile Ads
-keep public class com.google.android.gms.ads.** { public *; }
-keep public class com.google.ads.** { public *; }

# Firebase
-keepattributes *Annotation*
-keepattributes Signature
```

---

## 5. Build Production Android App Bundle (.aab)

Run the release build command from the project root:

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

The output bundle will be located at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 6. Google Play Console Listing Checklist

- [ ] **App Title**: TraceCraft — AR Drawing & Tracing Assistant
- [ ] **Short Description**: Overlay reference sketches onto live paper & trace exact outlines.
- [ ] **App Icon**: 512 × 512 px PNG (32-bit color).
- [ ] **Feature Graphic**: 1024 × 500 px PNG/JPEG.
- [ ] **Phone Screenshots**: Minimum 4 high-res screenshots (16:9 or 18:9) demonstrating:
  1. Live Camera Lucida Tracing Canvas with Opacity Slider.
  2. Sobel Edge-Detection / Line-Art Extraction.
  3. Proportion Grid & Rule-of-Thirds Guide.
  4. Search Library & Community Showcase.
- [ ] **Content Rating**: Complete IARC Questionnaire (Rating: Everyone / 3+).
- [ ] **App Category**: Art & Design / Productivity.
