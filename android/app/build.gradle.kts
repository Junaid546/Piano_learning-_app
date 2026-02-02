import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystoreFile = rootProject.file("keystore.properties")
if (keystoreFile.exists()) {
    keystoreProperties.load(keystoreFile.inputStream())
}

android {
    namespace = "com.example.pianoapp"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        @Suppress("DEPRECATION")
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.pianoapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "pianoapp-key"
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: "pianoapp123"
            storeFile = keystoreProperties.getProperty("storeFile")?.let { path -> rootProject.file(path) }
                ?: file("pianoapp-release-key.jks")
            storePassword = keystoreProperties.getProperty("storePassword") ?: "pianoapp123"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Ensure universal APK (no ABI split)
    splits {
        abi {
            isEnable = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
