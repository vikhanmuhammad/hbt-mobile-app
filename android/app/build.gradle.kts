plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.habbit_tracker_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires core library desugaring.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.habbit_tracker_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 24 is required by flutter_local_notifications.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs
            .map { it as com.android.build.gradle.internal.api.BaseVariantOutputImpl }
            .forEach { output -> output.outputFileName = "habit_tracker.apk" }

        // `flutter build apk` always re-copies the Gradle output into
        // build/app/outputs/flutter-apk/ under its own app-<buildmode>.apk name
        // (hardcoded in the Flutter Gradle plugin, not overridable from here),
        // so mirror our renamed APK there too under the name we actually want.
        variant.assembleProvider.configure {
            doLast {
                val src = File(
                    project.layout.buildDirectory.dir("outputs/apk/${variant.name}").get().asFile,
                    "habit_tracker.apk",
                )
                if (src.exists()) {
                    val destDir = project.layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
                    destDir.mkdirs()
                    src.copyTo(File(destDir, "habit_tracker.apk"), overwrite = true)
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
