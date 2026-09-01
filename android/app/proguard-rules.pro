# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive TypeAdapters
-keep class com.tracecraft.app.trace_craft.models.** { *; }
-keepclassmembers class * extends io.flutter.plugin.common.StandardMessageCodec { *; }

# Google Mobile Ads (AdMob)
-keep public class com.google.android.gms.ads.** { public *; }
-keep public class com.google.ads.** { public *; }

# Firebase Cloud Firestore & Storage & Auth
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*
-keepattributes Signature

# Flutter Deferred Components & Google Play Core
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**
-keep class com.google.android.play.core.** { *; }

