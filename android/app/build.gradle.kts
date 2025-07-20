plugins {
    id("com.android.application")
    id("kotlin-android") // Menggunakan "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.keuangan_baru"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Pastikan ada tanda kutip ganda

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // BARIS INI ADALAH LOKASI YANG BENAR UNTUK MENGAKTIFKAN DESUGARING
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.keuangan_baru"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        // HAPUS BARIS coreLibraryDesugaringEnabled = true DARI SINI
        // coreLibraryDesugaringEnabled = true // <--- HAPUS BARIS INI
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependensi untuk desugaring (INI TETAP DI SINI)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
