allprojects {
    repositories {
        google()
        mavenCentral()
    }

    dependencyLocking {
        lockAllConfigurations()
        //ignore the flutter dependencies since they are not published to maven and are not needed for the lock file
        ignoredDependencies.add("io.flutter:*")
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
