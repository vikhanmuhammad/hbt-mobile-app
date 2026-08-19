allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Some plugins (e.g. `health`) hardcode an older compileSdk in their own
// android/build.gradle that's now too low for their own transitive deps
// (Health Connect requires compileSdk >= 35). Force every Android library
// subproject onto the same compileSdk as :app instead of patching each
// plugin's build.gradle by hand (which lives in the pub cache and would be
// overwritten on the next `pub get`). Must run in `afterEvaluate` — the
// plugin's own build.gradle sets `compileSdk 34` inside its `android {}`
// block, which is only fully applied once that subproject itself finishes
// evaluating, so an override applied any earlier gets clobbered by it.
subprojects {
    val applyCompileSdkOverride = {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
    // `evaluationDependsOn(":app")` above can cause some subprojects to
    // already be fully evaluated by the time this block runs for them,
    // and `afterEvaluate` throws if called on an already-evaluated
    // project — apply immediately in that case instead.
    if (state.executed) applyCompileSdkOverride() else afterEvaluate { applyCompileSdkOverride() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
