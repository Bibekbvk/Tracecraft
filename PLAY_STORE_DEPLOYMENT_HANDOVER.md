# TraceCraft - Project Handover & Deployment Summary

## 📌 Project Overview
* **Application**: **TraceCraft - AR Drawing & Tracing**
* **Application ID / Package Name**: `com.tracecraft.app.trace_craft`
* **Version**: `1.0.10` (Version Code: `10`)
* **GitHub Repository**: [https://github.com/Bibekbvk/Tracecraft.git](https://github.com/Bibekbvk/Tracecraft.git)
* **Active Branches**: `main` and `feature/production-release` (Both fully synchronized with origin).

---

## 🚀 Google Play Store Deployment State

### 1. Release Track Status
* **Closed Testing (Alpha)**: **`🕒 In review`**
  * Version Code: `10` (`app-release.aab` - 52.2 MB)
  * Target Countries: **177 of 177 Countries** (Full Rollout)
* **Internal Testing**: **`🟢 Available to internal testers`**

### 2. Store Presence & Declarations Completed
* **App Name**: `TraceCraft - AR Drawing & Tracing`
* **Short Description**: `Trace and sketch any image on paper using Camera Lucida AR optical overlays.`
* **App Icon**: `512 x 512 px` ([`assets/images/app_icon_512.png`](file:///c:/Users/Asus/Desktop/vibe/Disaster%20Nepal/assets/images/app_icon_512.png))
* **Feature Graphic**: `1024 x 500 px` ([`assets/images/play_store_feature_graphic_1024x500.png`](file:///c:/Users/Asus/Desktop/vibe/Disaster%20Nepal/assets/images/play_store_feature_graphic_1024x500.png))
* **Privacy Policy URLs**:
  * Web / HTML: `https://bibekbvk.github.io/Tracecraft/privacy_policy.html`
  * Markdown: `https://github.com/Bibekbvk/Tracecraft/blob/main/PRIVACY_POLICY.md`
* **Policy Declarations Completed**:
  * ✅ Data Safety Questionnaire
  * ✅ Advertising ID Declaration (AdMob / Marketing)
  * ✅ Target Audience & Content Rating (Families Policy Commitment)
  * ✅ Government / Financial / Health Declarations

---

## 📱 Hardware & On-Device Validation

* **Device Tested**: `ALI NX1` (Android 15)
* **Status**: **Verified & Running Live**
* **Verified Features**:
  * Real-time Camera Lucida optical overlay projection
  * AI edge-detection outline filter
  * Opacity slider (0% to 100%)
  * Grid guides & Canvas lock
  * Online multi-source image search & local gallery picker
  * Google Mobile Ads SDK test banner rendering

---

## 🛠️ Key Production Artifacts & File Locations

| File | Purpose | Location |
| :--- | :--- | :--- |
| **Release AAB** | Google Play App Bundle (`v10`) | `build/app/outputs/bundle/release/app-release.aab` |
| **Release APK** | Direct Device Installation | `build/app/outputs/flutter-apk/app-release.apk` |
| **Keystore** | App Signing Key | `android/app/upload-keystore.jks` |
| **Keystore Config** | Key Credentials | `android/key.properties` |
| **ProGuard Rules** | R8 Shrinking & Code Minification | `android/app/proguard-rules.pro` |
| **AdMob Service** | Ads Management & Unit IDs | `lib/services/ad_service.dart` |
| **Privacy Policy** | Store Compliance Documentation | `PRIVACY_POLICY.md` & `privacy_policy.html` |

---

## 💰 Next Steps for Future AdMob Revenue

When switching from Test Mode to Live Earnings:
1. Obtain real IDs from [AdMob Console](https://admob.google.com).
2. Set `com.google.android.gms.ads.APPLICATION_ID` in `android/app/src/main/AndroidManifest.xml`.
3. Set `useProductionAds = true` and paste unit IDs in `lib/services/ad_service.dart`.
4. Link AdMob to the approved Google Play Store listing.
