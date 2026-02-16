// 1. เพิ่มบล็อกนี้ไว้บนสุดของไฟล์
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ปรับเป็นเวอร์ชัน 1.9.0 หรือสูงกว่าเพื่อให้รองรับ nfc_manager
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ... โค้ดส่วน newBuildDir เดิมของคุณ ...
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