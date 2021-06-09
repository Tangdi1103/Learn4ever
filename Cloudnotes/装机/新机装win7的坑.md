<font size=4>

##### 预备知识
- 1、UEFI启动模式对应可操作的硬盘分区为GPT
- 2、Legacy启动模式对应可操作的硬盘分区为MBR

GPT和MBR分区格式可以互换，但MBR无法识别磁盘空间超2TB的分区，而GPT可以。

格式化磁盘，需注意4K对齐。一般大空间的固态硬盘需要4K分区对齐选择4096K扇区。



详细微PE使用教程请查阅->
[微PE使用说明书](http://www.wepe.com.cn/ubook/)

---
##### 安装完成后，因为Win7系统自带驱动缺少部分新机所需的驱动，需进行以下设置才能正常启动Win7
1、Fn + F2进入BIOS界面（不同机器请自行查询进入方式）

2、EXIT -> OS optimized Defaults 改成Win7 OS或者Other OS

3、Load Default setting恢复默认设置（能正常进入Win后，再重启设置）

4、BOOT -> BOOT Priority 设置成Legacy First

5、Confuguration -> Sata Controller mode 设置成Compatitible（兼容模式）

6、Confuguration -> Usb mode 设置成Usb2.0

##### 以上BIOS设置后正常进入Win7安装各种驱动后，重启进入Bios设伏默认设置Load Default setting

---