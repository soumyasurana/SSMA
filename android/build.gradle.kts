buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Updated Android Gradle Plugin (AGP) to a version compatible with Gradle 8.9+
        // AGP 8.1.4 is a stable version that works well with Gradle 8.x and supports 'namespace'.
        classpath("com.android.tools.build:gradle:8.1.4")
        // Keep Kotlin Gradle Plugin as is, assuming it's compatible.
        // If you encounter further Kotlin-related errors, this might need updating too.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}