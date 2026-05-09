# Flutter TV ProGuard Rules

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart
-keep class dart.** { *; }
-keep class package:flutter_tv.** { *; }

# Provider
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Hive
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Dio
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Video Player
-keep class com.google.android.exoplayer2.** { *; }

# Keep data models
-keep class com.example.flutter_tv.core.models.** { *; }

# General
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
