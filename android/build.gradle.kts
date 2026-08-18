buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("com.android.tools.build:builder-model:8.11.1")
    }
}

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

subprojects {
    val fixNamespace = Action<Project> {
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            val method = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
            val currentNamespace = androidExtension.javaClass.getMethod("getNamespace").invoke(androidExtension)
            if (currentNamespace == null) {
                method.invoke(androidExtension, "com.example.mobile." + name.replace("-", "_"))
            }
        }
    }
    if (state.executed) {
        fixNamespace.execute(this)
    } else {
        afterEvaluate { fixNamespace.execute(this) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
