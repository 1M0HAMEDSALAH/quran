# Keep audio player classes
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_service.** { *; }
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Keep connectivity classes
-keep class io.flutter.plugins.connectivity.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep GetX classes
-keep class com.jonatas.getx.** { *; }

# Don't obfuscate audio-related classes
-dontwarn com.ryanheise.just_audio.**
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**