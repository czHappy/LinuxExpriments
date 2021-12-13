
# 实验二 From GUI to CLI


# 实验环境
* 宿主机系统window10
* 虚拟机Ubuntu 18.04 Server 64bit
* vimtutor
* asciinema录屏工具

# 完成过程
* [Lesson1 ](https://asciinema.org/a/235235)
* [Lesson2](https://asciinema.org/a/235238)
* [Lesson3](https://asciinema.org/a/235239)
* [Lesson4](https://asciinema.org/a/235241)
* [Lesson5](https://asciinema.org/a/235243)
* [Lesson6](https://asciinema.org/a/235248)
* [Lesson7](https://asciinema.org/a/235250)
* [完整录屏](https://asciinema.org/a/234970)

# vimtutor完成后的自查清单

---

* 你了解vim有哪几种工作模式？
    - Normal Mode 刚进去的页面是Normal Mode，按a i o进入文本输入模式
    -  Insert Mode 正在对文本进行操作，按ESC进入Normal Mode
    - Visual Mode 在Normal Mode下按v进入Visual Mode，有点像按下鼠标拖动的感觉

* Normal模式下，从当前行开始，一次向下移动光标10行的操作方法？如何快速移动到文件开始行和结束行？如何快速跳转到文件中的第N行？
    - Normal Mode下，按下10j可使光标一次向下移动10行
    - gg 移动到开始行
    - G 移动到最后一行
    - nG  移动到这个文件的第n行  例如58G
* Normal模式下，如何删除单个字符、单个单词、从当前光标位置一直删除到行尾、单行、当前行开始向下数N行？
    - x 删除当前光标所指的单个字符
    - dw 删除光标之后的单词剩余部分，若删除单个单词则将光标指到单词开始第一个字符
    - d$ 从当前位置一直删除到行尾
    - dd 删除单行
    - Ndd删除当前行开始向下N行

* 如何在vim中快速插入N个空行？如何在vim中快速输入80个-？
  * No 在当前行下插入N个空行并进入 Insert Mode，按下ESC返回Normal Mode可以得到N个空行
  * Normal Mode下按下 Nix 再按下EXC表示插入N个字符x，此处N=80 x='-'
  
* 如何撤销最近一次编辑操作？如何重做最近一次被撤销的操作？
  * u 撤销最近一次编辑
  * ctrl + r 重做最近一次被撤销的操作
  
* vim中如何实现剪切粘贴单个字符？单个单词？单行？如何实现相似的复制粘贴操作呢？
  * 剪切单个字符用x再加p
  * 剪切单个单词用dw再加p
  * 剪切单行用dd再加p
  * 复制同样道理，把d换成y即可，y,yw,yy

---

* 为了编辑一段文本你能想到哪几种操作方式（按键序列）？
  * 按i进入 Insert Mode，移动光标编辑文本
  * 按a在单词后追加
  * 按o新起一行插入文本


* 查看当前正在编辑的文件名的方法？查看当前光标所在行的行号的方法？
  * ctrl + G 在末行可看到文件名和当前行号


* 在文件中进行关键词搜索你会哪些方法？如何设置忽略大小写的情况下进行匹配搜索？如何将匹配的搜索结果进行高亮显示？如何对匹配到的关键词进行批量替换？
  * /key  key是关键词
  * :set ic回车后再用/key查找关键词将 ignore case，:set noic取消忽略
  * :set hlsearch 再用/key查找关键词将会把所有匹配的关键字高亮显示， nohlsearch取消
  * :s/old/new/ 替换当前行第一个 old 为 new 
  * :s/old/new/g 替换当前行中所有 old 为 new 
  * :%s/old/new/ 替换文中所有第一行的  old 为 new
  * :%s/old/new/g 替换文中所有old 为 new
  * :#,#s/old/new/g 在行范围[#,#]进行全局替换
  
* 在文件中最近编辑过的位置来回快速跳转的方法？
  * Ctrl+O 快速回到上一次光标所在位置 O代表Older
  * Ctrl+I 快速回到下一次光标所在位置


* 如何把光标定位到各种括号的匹配项？例如：找到(, [, or {对应匹配的),], or }
  * 在光标移至括号 再按%可使光标定位到它的匹配括号


* 在不退出vim的情况下执行一个外部程序的方法？
  * 可以在Normal Mode下输入 :! command，如 :! ls查看当前目录
  * 另外一种暂时退出vim的方法，可以在Normal Mode下输入 :shell 跳转到命令行窗口，执行完命令后再按exit就自动跳回vim

* 如何使用vim的内置帮助系统来查询一个内置默认快捷键的使用方法？如何在两个不同的分屏窗口中移动光标？
  * Normal Mode下，按:help command 可以查看该command的使用方法
  * ctrl + w在不同分屏切换 类似于Windows的ctrl + TAB
  * ctrl + k、j、h、l分别切换到上下左右屏幕

# 参考资料
* [课件](http://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/chap0x02.exp.md.html#/title-slide)
* [实验二指导书](https://github.com/c4pr1c3/LinuxSysAdmin/blob/master/chap0x02.exp.md)