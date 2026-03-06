# Flutter specific rules (essential for keeping Flutter engine classes)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class com.example.ssma.** { *; } # Keep your main activity and any other app-specific classes

# Rules for Isar (essential for keeping Isar's native and generated code)
# Isar often needs specific rules to prevent R8 from stripping its internal components.
# These are general recommendations, Isar's official docs might have more specific ones.
-keep class io.isar.** { *; }
-keep class * extends io.isar.IsarCollection { *; }
-keep class * extends io.isar.IsarObject { *; }
-keep class * implements io.isar.IsarCollection { *; }
-keep class * implements io.isar.IsarObject { *; }
-keep @io.isar.Collection class * { *; }
-keep @io.isar.Index class * { *; }
-keep @io.isar.Id class * { *; }
-keep @io.isar.Backlink class * { *; }
-keepclassmembers class * {
    @io.isar.Id <fields>;
    @io.isar.Index <fields>;
    @io.isar.Backlink <fields>;
}

# General Android and third-party library rules (often needed)
-keep class android.webkit.** { *; }
-keep class android.net.** { *; }
-keep class android.os.** { *; }
-keep class android.view.** { *; }
-keep class android.widget.** { *; }
-keep class android.content.** { *; }
-keep class android.util.** { *; }
-keep class android.app.** { *; }
-keep class android.R$* { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Keep all annotations
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable
-keepattributes EnclosingMethod
-keepattributes Deprecated
-keepattributes Synthetic
-keepattributes Bridge
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations
-keepattributes AnnotationDefault
-keepattributes ConstantValue

# For any third-party libraries that might use reflection or native code,
# you might need to add specific -keep rules as per their documentation.
# For example, if you use a JSON serialization library that uses reflection:
# -keep class com.your.json.models.** { *; }
