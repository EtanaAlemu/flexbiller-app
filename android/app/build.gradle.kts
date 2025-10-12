import java.io.FileInputStream
import java.util.*
import java.io.ByteArrayOutputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("✓ Loaded keystore properties")
} else {
    println("✗ Warning: keystore.properties not found")
}

// ===== VERSION CONFIGURATION =====
// Load version properties
val versionPropsFile = rootProject.file("version.properties")
val versionProps = Properties()
if (versionPropsFile.exists()) {
    versionProps.load(FileInputStream(versionPropsFile))
    println("✓ Loaded version properties")
} else {
    println("✗ Warning: version.properties not found, using defaults")
    // Set defaults if file doesn't exist
    versionProps.setProperty("major", "1")
    versionProps.setProperty("minor", "0")
    versionProps.setProperty("patch", "0")
}

// MANUAL: Update these for each release (loaded from version.properties)
val majorVersion = versionProps.getProperty("major", "1").toInt()
val minorVersion = versionProps.getProperty("minor", "0").toInt()
val patchVersion = versionProps.getProperty("patch", "0").toInt()

// AUTOMATIC: Git-based build numbers (inline to avoid function conflicts)
val versionCodeGit = try {
    val output = ByteArrayOutputStream()
    exec {
        commandLine("git", "rev-list", "--count", "HEAD")
        standardOutput = output
    }
    output.toString().trim().toInt()
} catch (e: Exception) {
    println("Warning: Using fallback version code")
    1
}

val gitCommitHash = try {
    val output = ByteArrayOutputStream()
    exec {
        commandLine("git", "rev-parse", "--short", "HEAD")
        standardOutput = output
    }
    output.toString().trim()
} catch (e: Exception) {
    "unknown"
}

// Final version configuration
val versionCodeFinal = versionCodeGit  // Auto-incrementing from git
val versionNameFinal = "$majorVersion.$minorVersion.$patchVersion"  // Manual SemVer

println("=== Build Info ===")
println("Version: $versionNameFinal")
println("Version Code: $versionCodeFinal")
println("Git Commit: $gitCommitHash")
println("==================")

android {
    namespace = "org.aumtech.flexbiller"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = true
    }

    // Signing configurations
    signingConfigs {
        getByName("debug") {
            keyAlias = keystoreProperties.getProperty("debugKeyAlias", "flexbiller-debug")
            keyPassword = keystoreProperties.getProperty("debugKeyPassword", "flexbiller123")
            storeFile = file(keystoreProperties.getProperty("debugStoreFile", "../keystores/flexbiller-debug.keystore"))
            storePassword = keystoreProperties.getProperty("debugStorePassword", "flexbiller123")
        }
        create("release") {
            keyAlias = keystoreProperties.getProperty("releaseKeyAlias") 
                ?: throw GradleException("releaseKeyAlias not found in keystore.properties")
            keyPassword = keystoreProperties.getProperty("releaseKeyPassword") 
                ?: throw GradleException("releaseKeyPassword not found in keystore.properties")
            storeFile = file(keystoreProperties.getProperty("releaseStoreFile") 
                ?: throw GradleException("releaseStoreFile not found in keystore.properties"))
            storePassword = keystoreProperties.getProperty("releaseStorePassword") 
                ?: throw GradleException("releaseStorePassword not found in keystore.properties")
        }
    }

    defaultConfig {
        applicationId = "org.aumtech.flexbiller"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // VERSION CONFIGURATION
        versionCode = versionCodeFinal
        versionName = versionNameFinal
        
        // Optional: Add build info for debugging
        buildConfigField("String", "BUILD_TIME", "\"${System.currentTimeMillis()}\"")
        buildConfigField("String", "GIT_COMMIT", "\"$gitCommitHash\"")
        buildConfigField("String", "VERSION_NAME", "\"$versionNameFinal\"")
        buildConfigField("int", "VERSION_CODE", "$versionCodeFinal")
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            // Add commit hash to debug builds for identification
            versionNameSuffix = "-debug.$gitCommitHash"
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}