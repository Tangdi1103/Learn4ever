在编辑/etc/profile

```
if [ "$PS1" ]; then
  if [ "$BASH" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

export JAVA_HOME=/usr/local/jdk1.8.0_152
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export MAVEN_HOME=/usr/local/apache-maven-3.5.3
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:${MAVEN_HOME}/bin:$PATH

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
```
###### ==添加一下信息==
```
export JAVA_HOME=/usr/local/jdk1.8.0_152
export JRE_HOME=/usr/local/jdk1.8.0_152/jre
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export MAVEN_HOME=/usr/local/apache-maven-3.5.3
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$MAVEN_HOME/bin:$PATH:$HOME/bin
```

###### ==使环境变量生效==

```
source /etc/profile
```
