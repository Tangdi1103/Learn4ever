[toc]

## HotSpot虚拟机插件及工具

[请自行百度或参考《深入理解Java虚拟机》第三版的第4.4章]()

##### HSDIS：即时编译器的反汇编插件

HSDIS是一个被官方推荐的HotSpot虚拟机即时编译代码的反汇编插件，它包含在HotSpot虚拟机 的源码当中，在OpenJDK的网站也可以找到单独的源码下载，但并没有提供编译后的程序。

HSDIS插件的作用是让HotSpot的 **`-XX:+PrintAssembly`**指令调用它来把即时编译器动态生成的本 地代码还原为汇编代码输出，同时还会自动产生大量非常有价值的注释，这样我们就可以通过输出的 汇编代码来从最本质的角度分析问题。读者可以根据自己的操作系统和处理器型号，从网上直接搜 索、下载编译好的插件，直接放到  **JDK_HOME/jre/bin/server目录（JDK 9以下） **或 JDK_HOME/lib/amd64/server（JDK 9或以上）中即可使用。如果读者确实没有找到所采用操作系统的 对应编译成品，那就自己用源码编译一遍（网上能找到各种操作系统下的编译教程）。 

- Linux和mac使用如下命令

  ```sh
  git clone https://github.com/liuzhengyang/hsdis
  cd hsdis
  tar -zxvf binutils-2.26.tar.gz
  make BINUTILS=binutils-2.26 ARCH=amd64
  ```

- windows查看以下github仓库

  ```
  https://github.com/doexit/hsdis.dll
  ```

  