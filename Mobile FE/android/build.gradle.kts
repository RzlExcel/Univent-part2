plugins {
    // Tambahkan ini di bagian atas file:
    id("com.google.gms.google-services") version "4.4.1" apply false
}
// 1. Definisikan buildscript untuk Firebase & Google Services
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Ini adalah kunci agar aplikasi bisa membaca google-services.json
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// 2. Definisikan repositori yang dibutuhkan untuk Firebase & Flutter
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. Konfigurasi folder build agar rapi (keluar dari folder android)
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 4. Konfigurasi Clean Task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}