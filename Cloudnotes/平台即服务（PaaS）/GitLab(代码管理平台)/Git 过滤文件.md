### .gitattributes


```
# Windows-specific files that require CRLF:
*.bat       eol=crlf
*.txt       eol=crlf

# Unix-specific files that require LF:
*.java      eol=lf
*.sh        eol=lf
```

### .gitignore


```
target/
!.mvn/wrapper/maven-wrapper.jar

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### JRebel ###
rebel.xml

### MAC ###
.DS_Store

### Other ###
logs/
temp/
```

### .gitignore （gradle）


```
.gradle
/build/
!gradle/wrapper/gradle-wrapper.jar

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
<<<<<<< HEAD
/.gradle
/logs/
/out/
=======
/out
/gradle
>>>>>>> 174b97ebfb76895b82dafd73414d72ae795ed03a
/src/test/
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
nbproject/private/
build/
nbbuild/
dist/
nbdist/
.nb-gradle/


/gradlew
/gradle/
/gradlew.bat


gradlew
gradlew.bat


*/gradle/wrapper/gradle-wrapper.jar
*/gradle/wrapper/gradle-wrapper.properties

/.gitignore

```
