### Eureka的build.gradle
```
group 'com.xxx'
version '1.0-SNAPSHOT'


buildscript {
    ext {
        springBootVersion = '2.0.3.RELEASE'
    }
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
    }
}


apply plugin: 'java'
apply plugin: 'eclipse'
apply plugin: 'idea'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'

bootJar {
    baseName = 'mc-regcenter'
    version = '1.0.0'
}

sourceCompatibility = 1.8
targetCompatibility = 1.8

repositories {
    maven { url 'http://maven.aliyun.com/nexus/content/repositories/central' }
    mavenCentral()
}


dependencyManagement {
    imports {
        mavenBom 'org.springframework.cloud:spring-cloud-dependencies:Finchley.RELEASE'
    }
}

repositories {
    maven {
        url 'https://repo.spring.io/libs-milestone'
    }
}

dependencies {
    compile('org.springframework.cloud:spring-cloud-starter-netflix-eureka-server')
    compile('org.springframework.boot:spring-boot-starter-security')
    testCompile group: 'junit', name: 'junit', version: '4.12'
    fileTree(dir: 'lib', include: '*.jar')
}

jar {

    String someString = ''
    configurations.runtime.each {someString = someString + " lib\\"+it.name}
    manifest {
        attributes 'Main-Class': 'RunServer'
        attributes 'Class-Path': someString

    }

}

task clearPj(type:Delete){
    delete 'build','target'
}

task copyJar(type:Copy){
    from configurations.runtime
    into ('build/libs/lib')

}


task release(type: Copy,dependsOn: [build,copyJar]) {
//    from  'conf'
    //   into ('build/libs/eachend/conf')
}



task wrapper(type: Wrapper) {
    gradleVersion = '4.7'
}
```

### Zuul的build.gradle

```
group 'com.xxx'
version '1.0-SNAPSHOT'

buildscript{
    ext{
        springBootVersion = '2.0.3.RELEASE'
    }
    repositories{
        mavenCentral()
    }
    dependencies{
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
    }
}

apply plugin: 'java'
apply plugin: 'eclipse'
apply plugin: 'idea'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'

bootJar {
    baseName = 'mc-zuul'
    version = '1.0.0'
}

sourceCompatibility = 1.8
targetCompatibility = 1.8

repositories {
    maven { url 'http://maven.aliyun.com/nexus/content/repositories/central' }
    mavenCentral()
}

ext {
    springCloudVersion = 'Finchley.SR1'
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
    }
}

repositories {
    maven {
        url 'https://repo.spring.io/libs-milestone'
    }
}

dependencies {
    //compile("org.springframework:spring-context:4.3.8.RELEASE")

    compile('org.springframework.boot:spring-boot-starter-actuator')
    compile('org.springframework.boot:spring-boot-starter-web')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-zuul')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-ribbon')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-hystrix')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-hystrix-dashboard')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-eureka-client')
    fileTree(dir: 'lib', include: '*.jar')

}


jar {

    String someString = ''
    configurations.runtime.each {someString = someString + " lib\\"+it.name}
    manifest {
        attributes 'Main-Class': 'RunServer'
        attributes 'Class-Path': someString

    }

}

task clearPj(type:Delete){
    delete 'build','target'
}

task copyJar(type:Copy){
    from configurations.runtime
    into ('build/libs/lib')

}


task release(type: Copy,dependsOn: [build,copyJar]) {
//    from  'conf'
    //   into ('build/libs/eachend/conf')
}





task wrapper(type: Wrapper) {
    gradleVersion = '4.7'
}
```
