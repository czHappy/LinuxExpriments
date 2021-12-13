

# Sytemd入门教程实验

## 实验内容
- [Systemd 入门教程：命令篇 by 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：命令篇 by 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
- **实验要求：完整实验操作过程通过asciinema进行录像并上传，文档通过github上传**

## 实验录像
- systemd命令篇
    - [系统概述和管理 ![缩略图](https://asciinema.org/a/237329.png)](https://asciinema.org/a/237329) 
    - [Unit ![缩略图](https://asciinema.org/a/237347.png)](https://asciinema.org/a/237347)
    - [Unit配置文件和Targert ![](https://asciinema.org/a/237357.png)](https://asciinema.org/a/237357)
   
    - [日志管理![](https://asciinema.org/a/237363.png)](https://asciinema.org/a/237363)
    
- [systemd实战篇![](https://asciinema.org/a/236634.png)](https://asciinema.org/a/236634)

## 自查清单
- 如何添加一个用户并使其具备sudo执行程序的权限？
```bash
sudo adduser cheng#添加一个用户cheng
#方法1 修改sudoer文件
sudo vi /etc/sudoers #修改该文件
%cheng ALL=(ALL:ALL) ALL#在%sudo下添加这一行

#方法2 添加该用户到sudo用户组
sudo usermod -a -G sudo cheng
```
![图片](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/sudo.PNG?raw=true)
- 如何将一个用户(username)添加到一个用户组(usergroup)？ 
```bash
sudo usermod -a -G usergroup username
```
  
- 如何查看当前系统的分区表和文件系统详细信息？
```bash
sudo fdisk -l #查看当前系统分区表
 df -T -h  #查看文件系统详细信息：
 cat /etc/fstab # 查看文件系统详细信息：
```
![error](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/分区.PNG?raw=true)
   
- 如何实现开机自动挂载Virtualbox的共享目录分区？
 ```bash
#用VirtualBox虚拟机的共享文件夹设置共享的本地文件E:\vbshare

#在ubuntu中创建一个共享目录
mkdir /mnt/share

#root下执行挂载命令
mount -t vboxsf vbshare /mnt/share
 
#结果错误
mount: wrong fs type, bad option, bad superblock on /mnt/share, missing codepage or helper program, or other error

#原因是缺少挂载nfs格式的文件
apt-get install nfs-common

#重新挂载 
无效，没有解决该问题

```
![error](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/error.PNG?raw=true)

- 基于LVM（逻辑分卷管理）的分区如何实现动态扩容和缩减容量？
```bash
lvdisplay #查看lvm信息，找到对应的分区

lvreduce --size -1G  /dev/cuc-vg/root#缩减容量

lvextend --size +1G  /dev/cuc-vg/root#扩容

lvresize #命令可增可减，参数相同
```
![error](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/缩容.PNG?raw=true)
- 如何通过systemd设置实现在网络连通时运行一个指定脚本，在网络断开时运行另一个脚本？
```bash
#在与网络连通相关的配置文件/lib/systemd/system/systemd-networkd.service设置两个字段
#此处参考卢玉洁同学的文档，之前一直在改networking.service配置文件，发现不行，原来是上面那个配置文件

#不妨设这两个脚本为echo “something”

[Service]
ExecStartPost=/bin/echo post1
ExecStopPost=/bin/echo post2 
```
![](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/Exec.PNG?raw=true)

![](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/echo.PNG?raw=true)

- 如何通过systemd设置实现一个脚本在任何情况下被杀死之后会立即重新启动？实现**杀不死**？
```bash
#自定义一个服务，开机自启动，ExecStart字段设置为启动该脚本
#编写另外一个脚本文件x，该脚本用于启动该服务
#把这个自定义服务的ExecStop字段设置为启动脚本x
#现在想想不行，因为启动服务需要sudo权限，会要求输入密码......除非是root用户

#一种简单的方法是将该自定义service的[Service]区的Restart字段设置为always 
Restart=always #失败,一stop真stop了..
```
![](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/fail.PNG?raw=true)


## 实验问题
- 关于自动挂载共享文件夹问题的解决

 ```bash
 #网上大多数教程都是直接表明 `sudo mount -t vboxsf sharename  mountpath` 但是会报挂载点文件类型错误
 
#问题解决 安装virtbox工具集
  sudo apt-get install virtualbox-guest-utils
  
#挂载测试 ，不再报错，可以看到share.txt文件
 mount -t vboxsf vbshare /mnt/share
 
 #实现上一步后，/etc/rc.local 中追加如下命令实现开机自启动
 mount -t vboxsf vbshare /mnt/share
 
 #reboot后查看共享文件夹，发现不能自动挂载
 ```
 - rc.local
 查看相关资料后知道这个配置文件会在用户登陆之前读取，这个文件中写入了什么命令，在每次系统启动时都会执行一次。也就是说，如果有任何需要在系统启动时运行的工作，则只需写入 /etc/rc.local 配置文件即可。但事实上，通过文件搜索，本机并没有内置的/etc/rc.local文件。可能是该版本系统的相关配置文件已经更改了。
 
 - 自己尝试编写一个service来控制挂载命令自动执行
 ```bash
#首先建立一个service 
sudo vi /etc/systemd/system/rc-local.service
#在该service写入如下内容

[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local 
 
[Service]
Type=forking
ExecStart=/etc/rc.local start   #为了启动这个脚本
TimeoutSec=0
RemainAfterExit=yes
 
[Install]
WantedBy=multi-user.target

#根据命令篇教程，systemctl enable命令相当于激活开机启动，将该服务开机自启
sudo systemctl enable rc-local.service#f返回结果是建立了链接

#在之前的rc.local里面编写挂载共享文件的命令
!/bin/sh -e
mount -t vboxsf vbshare /mnt/share
exit 0

#赋予rc.local 执行权限
sudo chmod +x /etc/rc.local

#reboot之后自动挂载正常
```
![](https://github.com/CUCCS/linux-2019-czHappy/blob/exp03/exp03/image/share.PNG?raw=true)

 ## 实验感悟
 - 本次实验印象最深的是service，通过service可以控制许多脚本命令的执行，也可以管理开机自启动项。在service的配置文件中我们可以通过对各个字段进行设置，达到许多预期的功能。



## 参考资料
- [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
- [LVM wiki](https://wiki.debian.org/LVM)
- [建立自定义service](https://wiki.debian.org/systemd/Services?highlight=%28systemctl%29%7C%28service%29)
- [luyj](https://github.com/CUCCS/linux-2019-luyj/blob/Linux_exp0x03/Linux_exp0x03/Systemd%E5%85%A5%E9%97%A8.md)
