# 🚀 TraceCraft — Complete Play Store Deployment Handover & Project Summary

This document preserves all project configurations, keystore credentials, branch states, security specifications, and step-by-step Google Play Console deployment guidelines for seamless continuation across accounts.

---

## 📌 1. Repository & Package Architecture

* **Remote Repository**: [https://github.com/Bibekbvk/Tracecraft.git](https://github.com/Bibekbvk/Tracecraft.git)
* **Package Name (Application ID)**: `com.tracecraft.app.trace_craft`
* **App Display Name**: `TraceCraft`
* **Active Branches**:
  * `main` — Production-ready code synced with the latest release features.
  * `feature/production-release` — Dedicated release branch matching `main`.
* **Git Status**: Fully committed and pushed (`Working tree clean`).

---

## 🔑 2. Android Upload Keystore & Signing Config

The app is configured for Google Play App Signing with the following production keystore:

* **Keystore Location**: `android/app/upload-keystore.jks`
* **Keystore Properties File**: `android/key.properties`
* **Keystore Alias**: `upload`
* **Key Password**: `tracecraft2026`
* **Store Password**: `tracecraft2026`
* **Key Algorithm**: RSA 2048-bit (Validity: 10,000 days / ~27 years)

> **Important**: `key.properties` and `upload-keystore.jks` are saved locally. Never commit passwords or raw keystores to public GitHub.

---

## 📦 3. Compiled Release Artifacts Ready for Play Store

| Asset | Path | Specs / Dimensions | Purpose |
| :--- | :--- | :--- | :--- |
| **Android App Bundle (.aab)** | `build/app/outputs/bundle/release/app-release.aab` | **54.6 MB** (Signed Release) | Upload directly to Google Play Console Releases |
| **App Icon** | `assets/images/tracecraft_app_logo.png` | **512 x 512 px (PNG 32-bit)** | Play Store App Icon |
| **Feature Graphic** | `assets/images/play_store_feature_graphic.png` | **1024 x 500 px (PNG)** | Play Store Header Banner |

---

## 🛡️ 4. Security & Architecture Specifications

1. **Sliding-Window Rate Limiting (`SecurityService`)**:
   * OTP Requests: Max 3 requests / min.
   * Search Queries: Max 40 requests / min.
   * Authentication: Max 5 attempts / min.
2. **Anti-Brute-Force Lockout**:
   * Locks OTP verification for 15 minutes after 5 failed attempts on an email.
3. **Man-In-The-Middle (MITM) Prevention & HTTPS Enforcement**:
   * Enforces strict HTTPS on all network endpoints.
   * Injects `X-Content-Type-Options`, `X-Frame-Options`, and `Strict-Transport-Security` headers.
4. **Session ID Management**:
   * 256-bit cryptographically secure session tokens (`tc_sess_...`) rotating automatically on login/logout/24h expiration.
5. **Key & Password Obfuscation**:
   * Rolling salt XOR-cipher + Base64 storage so raw API keys and passwords are never stored in cleartext.
6. **Input Sanitization**:
   * Strips XSS script tags, HTML injection, and control characters from search, captions, and titles.

---

## 🎨 5. Implemented Features Summary

* **3-Second Center-Outward Water Flood Splash Screen**:
  * Dynamic water animation with bi-directional center-outward progress flow.
* **Camera Lucida AR Optical Tracing Canvas**:
  * Live camera preview + overlay reference image with opacity slider (0% to 100%).
  * Real-time Sobel line-art edge detection with sensitivity threshold slider.
  * Canvas lock, flashlight torch, horizontal/vertical mirror flipping, 3x3 to 6x6 proportion grid overlays.
  * **Photo Gallery Import**: Pick custom images from local device gallery directly in the tracing screen or discover tab.
* **10-Second Non-Skippable Video Ads**:
  * Timed in-session sponsor ads every 4 minutes + on-demand reward button (`+24h Ad-Free Tracing`).
* **Multi-Source Internet Search Engine**:
  * Queries **Pexels**, **Wikimedia Commons**, and **Openverse** simultaneously for millions of sketches, anime, vehicles, portraits, and nature references.
  * Randomized discover feed on every launch/pull-to-refresh.
* **Authentication & Guest Mode**:
  * Email + 6-digit verification OTP flow with password setup.
  * Guest artist mode with public Community Gallery upload lock.
* **Navigation Drawer**:
  * Attached across all main tabs (`Discover`, `Projects`, `Gallery`, `Streaks`) for instant access to tutorials, settings, feedback, and auth state.

---

## 📋 6. Step-by-Step Google Play Console Deployment Guide

When you are ready to deploy to your Play Console account, follow these exact steps:

### **Step 1: Create App in Google Play Console**
1. Log into [Google Play Console](https://play.google.com/console).
2. Click **Create app**:
   * **App name**: `TraceCraft - AR Drawing & Tracing`
   * **Default language**: `English (United States)`
   * **App or game**: `App`
   * **Free or paid**: `Free`
   * Accept the Declarations and click **Create app**.

### **Step 2: Set Up Main Store Listing**
1. Navigate to **Grow** -> **Store presence** -> **Main store listing**.
2. **Short description** (up to 80 chars):
   > `Trace and sketch any image on paper using Camera Lucida AR optical overlays.`
3. **Full description** (up to 4000 chars):
   > `TraceCraft turns your phone into an optical Camera Lucida drawing assistant. Mount your device above paper, adjust opacity, extract high-contrast line-art outlines with edge detection, and sketch with pinpoint proportion grid guides. Search millions of reference images across the internet or import your own photos from your gallery.`
4. **Graphics Assets**:
   * **App icon**: Upload `assets/images/tracecraft_app_logo.png` (512x512).
   * **Feature graphic**: Upload `assets/images/play_store_feature_graphic.png` (1024x500).
   * **Phone Screenshots**: Take 2 to 8 screenshots from your phone or emulator.

### **Step 3: Complete App Content Declarations**
Go to **Policy** -> **App content** and complete:
* **Privacy Policy**: Provide a valid URL or host a simple GitHub Pages privacy policy.
* **Ads**: Check **"Yes, my app contains ads"** (since AdMob is integrated).
* **App Access**: Check **"All functionality is available without special access"** (or specify Guest/Registered access).
* **Content Rating**: Complete the IARC questionnaire (select "Utility / Productivity / Art" -> Rating will be **Everyone / PEGI 3**).
* **Target Audience**: Select **13 and older** (or 18+).
* **Data Safety**: Declare that email is collected for account login/authentication (encrypted in transit).

### **Step 4: Upload Release App Bundle (.aab)**
1. Navigate to **Release** -> **Production** (or **Testing** -> **Closed testing** / **Internal testing**).
2. Click **Create new release**.
3. Under **App bundles**, upload:
   `build/app/outputs/bundle/release/app-release.aab`
4. Enter Release Name (e.g. `1.0.0 (1)`) and Release Notes:
   ```
   Initial release of TraceCraft:
   - AR Camera Lucida tracing with opacity & alignment grid
   - Real-time line-art outline edge detection
   - Multi-source internet image search & photo gallery import
   - Email verification with 6-digit OTP & guest artist mode
   ```
5. Click **Next** -> **Review release** -> **Start rollout to Production**!

---

## 🛠️ Quick Commands Reference for New Session

```bash
# Verify test suite
flutter test

# Verify zero lint/static errors
flutter analyze

# Rebuild signed release bundle if needed
flutter build appbundle --release

# Run live on connected device over Wi-Fi
flutter run -d 192.168.18.104:40129
```
