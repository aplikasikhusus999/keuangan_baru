// file: android/build.gradle.kts

buildscript {
    val kotlinVersion = "1.9.22" // Pindahkan ke dalam buildscript
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Mengatur direktori build untuk root proyek Android dan semua subproyek
// agar mengarah ke direktori build di root proyek Flutter.
// Ini akan membuat output build seperti APK ada di keuangan_baru/build/app/outputs/flutter-apk/
val flutterRoot = rootProject.projectDir.parentFile
val flutterBuildDir = flutterRoot.resolve("build")

rootProject.layout.buildDirectory.set(flutterBuildDir)

subprojects {
    // Untuk setiap subproyek (misalnya :app, :flutter_local_notifications),
    // atur direktori build mereka di dalam direktori build utama Flutter.
    project.layout.buildDirectory.set(flutterBuildDir.resolve(project.name))
}

// Task clean untuk menghapus direktori build utama Flutter
// Ini akan menghapus folder 'build' di root proyek Flutter Anda.
tasks.register<Delete>("clean") {
    delete(flutterBuildDir)
}
