# 无人值守Ubuntu18.04 ISO 安装

------

## 一、实验环境以及任务
###     *环境 宿主机wind7 虚拟机 ubuntu-18.04.1-server-amd64* 
- [x] 新添加的网卡如何实现系统开机自动启用和自动获取IP？
- [x] 如何使用psftp在虚拟机和宿主机之间传输文件？
- [x] 如何配置无人值守安装ubuntu-18.04.1-server-amd64镜像并在Virtualbox中完成自动化安装？
- [x] 对比定制文件和官方示例文件



## 二、添加网卡并设置自动启动和自动获取IP
-  首先手动安装Ubuntu18.04.1-server-amd64.iso镜像 

-  在虚拟机为该系统配置第二块网卡 host-only，开机时自动启动 

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/add-adapter.PNG)

- 启动虚拟机，查看配置ifconfig -a,可以看到第二块网卡enp0s8未分配IP

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/ifconfig.PNG)

方法(1): 手动启动，下次开机时若需要启动则需要再次输入命令
`sudo dhclient enp0s8` 
方法(2): 修改配置文件  开机自动获取IP   
`sudo vi /etc/netplan/01-netcfg.yaml`

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/aotu-start.PNG)


- 启动之后查看网卡ip  

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/adapter-active.PNG)


------

## 三、使用PSFTP在虚拟机和宿主机之间传输文件

- 首先连接putty，确保虚拟机已经安装ssh服务 

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/login-putty.PNG)

- 打开psftp, open 192.168.56.102，即打开已经连接的主机

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/log-psftp.PNG)

- 传输镜像文件时，首先把镜像文件放在和psftp同一目录下方便传输（或者传输时指定绝对路径），进入虚拟机当前用户目录下，使用put命令

`put ubuntu-18.04.1-server-amd64.iso`

 ![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/put-iso.PNG)

 

## 四、无人值守Ubuntu18.04 ISO 制作


- 在当前用户目录下创建一个用于挂载iso镜像文件的目录

  `mkdir loopdir`
 
- 挂载iso镜像文件到该目录

  `sudo mount -o loop ubuntu-18.04.1-server-amd64.iso loopdir`

- 创建一个工作目录用于克隆光盘内容

  `mkdir cd`
 
- 同步光盘内容到目标工作目录

  `sudo rsync -av loopdir/ cd`

- 卸载iso镜像

  `umount loopdir`
 
- 进入工作目录编辑Ubuntu安装引导界面增加一个新菜单项入口,添加以下内容

    `sudo vi isolinux/txt.cfg`
     
    ```
         label autoinstall   menu label ^Auto Install Ubuntu Server    
         kernel /install/vmlinuz   
         append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed     
         debian-installer/locale=en_US   console-setup/layoutcode=us    
         keyboard-configuration/layoutcode=us   
         console-setup/ask_detect=false  
         localechooser/translation/warn-light=true    
         localechooser/translation/warn-severe=true   
         initrd=/install/initrd.gz root=/dev/ram    
         rw quiet
    ```
     
 ![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/adit-txt-cfg.PNG)
  
- 下载 ubuntu-server-autoinstall.seed  至  home/cz/cd/preseed

`put ubuntu-server-autoinstall.seed`

`sudo mv ubuntu-server-autoinstall.seed /home/cz/cd/preseed/ `


- 修改isolinux/isolinux.cfg,修改内容 timeout 10

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/edit-timeout.PNG)
 
- 制作镜像
- 重新生成md5sum.txt,注意赋予相应的权限
```
chmod 777 md5sum.txt
cd ~/cd && find . -type f -print0 | xargs -0 md5sum > md5sum.txt
```
- 配置镜像名和目标路径
```
IMAGE=custom.iso
BUILD=/home/cz/cd/
```
- 执行制作镜像命令,需要先安装mkisoimage
 
 ```
 mkisofs -r -V "Custom Ubuntu Install CD" \
             -cache-inodes \
             -J -l -b isolinux/isolinux.bin \
             -c isolinux/boot.cat -no-emul-boot \
             -boot-load-size 4 -boot-info-table \
             -o $IMAGE $BUILD
```
- 出现无法定位软件包时按如下命令解决

`sudo apt-get update`

![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/get-gen-fail.PNG)
        
- 最后把制作完成的custom.iso传送至宿主机

     `get custom.iso`

    ![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/get-iso.PNG)


---

## 五、 自动安装过程

 - 新建虚拟机，把制作好的镜像custome.iso添加进光盘，然后启动就OK了
 - 安装完成后需要输入用户名密码，可以查看ubuntu-server-autoinstall.seed文件
 - **[自动安装过程录屏链接][1]**

&nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/image/login.PNG)


---
## 六、 定制好的seed文件与官方实例文件对比

 - 使用在线[文本对比工具][1]对比文本内容
 - 安装语言 国家 编码方式
&nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/1.PNG)
<br>   

 - 缩短网络连接（包括网络连接和dhcp服务器连接）超时时间和手动配置网络
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/2.PNG)
<br>

 - 添加静态网络配置
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/3.PNG)
<br>

 - 设置主机和域名
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/4.PNG)
<br>

 - 设置用户名和密码,记住它方便在安装完成登录时使用
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/6.PNG)
<br>

 - 设置时区 亚洲上海
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/7.PNG)
<br>

 - 选择最大空闲分区
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/11.PNG)
<br>

 - 设置逻辑卷管理分区，逻辑卷大小设置为最大，独立/home、/var和/tmp分区
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/8.PNG)
<br>

 - apt安装，设置不适用镜像
&nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/9.PNG)
<br>

 - 安装可选软件包，安装openssh,卸载引导程序后不自动更新。并且设置更新策略为：禁止自动更新
 &nbsp;&nbsp;&nbsp;&nbsp;![图片](https://github.com/CUCCS/linux-2019-czHappy/raw/exp01/exp01/image/text_contrast/10.PNG)

## 七、实验中遇到的问题以及解决
- 经常出现permission deny,则需要使用sudo提升权限

- 下载安装genisoimage软件包出现不能定位软件包错误，后来使用
`sudo apt-get update `

- 把l（L）看成I(i)，低级错误。对于这样的代码要么复制粘贴，要自己手敲就要看仔细。

- 踩坑，修改txt.cfg配置文件时没有把autoinstall标签内容置顶，导致镜像安装时不能自动安装，在此之前没有看到老师的教程，后来查到了按照老师的教程做了一遍。

- markdown格式问题，在在线编辑器中没有问题，上传至github预览格式乱了，原因是前后标记不对应。并且使用了过多不恰当的引用符号，以后多阅读其他排版很好的同学文档，学习学习。

## 参考资料

 - http://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/chap0x01.exp.md.html#/title-slide
 - https://www.cnblogs.com/everyday0error/p/5316363.html vim使用方法 
 - https://help.ubuntu.com/lts/installation-guide/example-preseed.txt


  [1]: https://www.bilibili.com/video/av46323591/