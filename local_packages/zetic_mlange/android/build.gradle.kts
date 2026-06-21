plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.zeticai.mlange.flutter"
version = "1.8.1"

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

android {
    namespace = "com.zeticai.mlange.flutter"
    compileSdk = 34

    defaultConfig {
        minSdk = 24
        consumerProguardFiles("consumer-rules.pro")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("com.zeticai.mlange:mlange:1.8.1")
    implementation("com.google.android.play:ai-delivery:0.1.1-alpha01")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
}
