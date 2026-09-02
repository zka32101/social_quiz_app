import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials are supplied via android/key.properties, which is
// git-ignored and never committed. Locally, copy key.properties.example to
// android/key.properties and fill in real values. In CI, the workflow writes
// this file (and the keystore it references) from GitHub Actions secrets.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.yourwish.shougakukore.shakai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.yourwish.shougakukore.shakai"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Manifest placeholder variables to ensure correct package name for content providers
        manifestPlaceholders = mapOf(
            "applicationId" to "com.yourwish.shougakukore.shakai",
            // Firebase messaging init provider
            "firebaseInitProviderAuthority" to "com.yourwish.shougakukore.shakai.firebaseinitprovider",
            // Androidx startup
            "startupAuthority" to "com.yourwish.shougakukore.shakai.androidx-startup",
            // Flutter share plugin
            "flutterShareAuthority" to "com.yourwish.shougakukore.shakai.flutter.share_provider",
            // Firebase messaging plugin
            "firebaseMessagingInitAuthority" to "com.yourwish.shougakukore.shakai.flutterfirebasemessaginginitprovider",
            // Google Mobile Ads
            "googleMobileAdsInitAuthority" to "com.yourwish.shougakukore.shakai.mobileadsinitprovider"
        )
    }

    buildTypes {
        release {
            // Falls back to the debug key when key.properties isn't present
            // (e.g. a plain `flutter build apk` without release credentials)
            // so the build still succeeds instead of failing outright.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

// Task to remove old package name content providers from merged manifest
afterEvaluate {
    tasks.findByName("processReleaseManifest")?.doLast {
        val manifestFile = file("$buildDir/intermediates/merged_manifest/release/AndroidManifest.xml")
        if (manifestFile.exists()) {
            var content = manifestFile.readText()
            // Replace old package name references in authorities
            content = content.replace(
                "com.petitworksapps.shougakukore.shakai",
                "com.yourwish.shougakukore.shakai"
            )
            manifestFile.writeText(content)
            println("✅ Manifest: Replaced old package name with new package name")
        }
    }
}
