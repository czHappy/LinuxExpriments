#!/bin/bash
function usage
{
    echo "Usage:"
    echo ""
    echo " ImageProcess.sh [-f filename][-cq percent][-cd percent][-cf][-am text][-as suffix][-ap prefix][-bp directory][-h]"
    echo ""
    echo "  command	arguments	description"
    echo "  -f,  		<filename>      The filename"
    echo "  -cq,		<percent>       Compress image quality"
    echo "  -cd, 		<percent>   	Compresse image distinguishability"
    echo "  -cf, 	                	Change image format to jpg"
    echo "  -am, 		<text>          Add text watermark"
    echo "  -as,		<text>          Add suffixname"
    echo "  -ap, 		<text>          Add prefixname"
    echo "  -bp, 		<directory>     Batch processing of image"
    echo "  -h,  "
}
#质量压缩 $1 百分比 $2文件名 保留原始图片和压缩后图片
function compress_quality
{
# echo "cq"
    STRING=$2
    path=${STRING%/*} #文件路径 不含文件名
    path=$path'/'
    file=${STRING##*/} #文件名 带后缀

    if [[ "$file" == "$STRING" ]]
    then
        path=""
    fi
    newname=$path"compress_qua_"$file
   # fo
   #带一点高斯模糊优化 压缩质量为参数$1%
    convert  -gaussian-blur 0.05 -quality $1% $2 $newname
    echo $2" Compress Finished!"       
}
#分辨率压缩 resize自动锁定宽高比 保留原始图片和压缩后图片
function compress_dis
{
    #echo "cd"
    STRING=$2
    path=${STRING%/*} #文件路径 不含文件名
    path=$path'/'
    file=${STRING##*/} #文件名 带后缀

    if [[ "$file" == "$STRING" ]]
    then
        path=""
    fi
    newname=$path"compress_dis_"$file

    $(convert -resize $1% $2 $newname)
    echo $2" Compress Finished!"        
}
#添加水印 添加在右下角 边距30 白色32点字体 
function add_watermark
{ 
    #echo "am"
    $(convert $1 -gravity southeast -geometry +30+30 -fill white -pointsize 32 -draw 'text 5,5 '\'$2\' $1)
    echo $1" Add Finished!"
}

#转换图片格式到jpg 并且后缀名为.jpg
function change_format
{
    #echo "cf"
    STRING=$1
    path=${STRING%/*} #文件路径 不含文件名
    path=$path'/'
    file=${STRING##*/} #文件名 带后缀
    if [[ "$file" == "$STRING" ]]
    then
        path=""
    fi
    filename=${file%.*} #裸的文件名 不带后缀
    format=${STRING:$[$(expr index $STRING .)-1]} #后缀名 带点.
echo "$STRING $path $file $filename $format $newname"
    $(convert $1 $path$filename'.jpg')
    echo "$1 change finished!"
}
function add_prefix
{
    #echo "ap"
    STRING=$1 #原始路径
    path=${STRING%/*} #文件路径 不含文件名
    path=$path'/'
    file=${STRING##*/} #文件名 带后缀

    if [[ "$file" == "$STRING" ]]
    then
        path=""
    fi
    filename=${file%.*} #裸的文件名 不带后缀
    format=${STRING:$[$(expr index $STRING .)-1]} #后缀名 带点.
    newname=$path$2$file
 
    $(mv $1 $newname)
    echo $1" Add Prefix Finished!"
}
function add_suffix
{
    #echo "as"
    STRING=$1 #原始路径
    path=${STRING%/*} #文件路径 不含文件名
    path=$path'/'
    file=${STRING##*/} #文件名 带后缀

    if [[ "$file" == "$STRING" ]]
    then
	path=""
    fi	
    filename=${file%.*} #裸的文件名 不带后缀
    format=${STRING:$[$(expr index $STRING .)-1]} #后缀名 带点. 
    newname=$path$filename$2$format 
#	echo "string = $STRING"
#	echo "path= $path"
#	echo "format = $format"
#	echo "file = $file"
#	echo "filename = $filename"
#	echo "newname = $newname"
    $(mv $1 $newname)
    echo $1" Add Suffix Finished!"
}
function batch_process
{
#    echo "bp"
    #能处理的文件格式 4种图片格式
    dic=('jpeg' 'jpg' 'png' 'svg') 
    dicname=$1
	last=${dicname: -1}
#	echo "last = $last.................................."
    if [[ $last != '/' ]];
    then
        dicname=$dicname'/'
    fi
	
#echo "STRING=$1 .......................... dicname=$dicname"
    for file in $(ls $dicname)
    do
	#echo "in.........."
        STRING=$file
	#提取该文件的格式 只处理4种format
        format=${STRING:$(expr index $STRING .)}
#	echo "string=$STRING format=$format"
        for form in ${dic[@]}
            do
                if [[ $form == $format ]]
                then
                    if [[ $ifcompqua ]]
                    then
                        compress_quality $quality $dicname$file
                    fi
                    if [[ $ifcompredis ]]
                    then
                        compress_dis $compressratio $dicname$file
                    fi
                    if [[ $iftextwatermark ]]
                    then
                        add_watermark $dicname$file $textcontent
                    fi
                    if [[ $ifchangeformat ]]
                    then
                        change_format $dicname$file
                    fi
                    if [[ $ifSuffixrename ]]
                    then
                        add_suffix $dicname$file $Suffix
                    fi
                    if [[ $ifPrefixrename ]]
                    then
			echo "flag"
                        add_prefix $dicname$file $Prefix
                    fi
                    break
                fi
            done
       # fi
    done
}
#如果参数个数是0则 弹出帮助信息
if [ $# == 0 ];
then
    usage
fi
#如果第1个参数不空 则指定文件 并要求有相应操作 对应操作的flag置为1
while [ "$1" != "" ]; do
    case $1 in
        -f )   shift #左移一个参数 即读取下一个参数 仍然名为$1
               if [[ $1 != -* && $1 ]]
               then
                filename=$1
               else
                echo "Warnning: There need a argument after -f"
                exit
               fi
               ;;
        -cq )  ifcompqua=1
               shift
               if [[ $1 != -* && $1 ]]
               then
                quality=$1
               else
                echo "Warnning: There need a argument after -cq"
                exit
               fi
               ;;
        -cd )  ifcompredis=1
               shift
               if [[ $1 != -* && $1 ]]
               then  
                compressratio=$1
               else
                echo "Warnning: There need a argument after -cd"
                exit
               fi
                ;;
        -cf )  ifchangeformat=1
                 ;;
        -am ) iftextwatermark=1
               shift
               if [[ $1 != -* && $1 ]]
               then
                textcontent=$1
               else
                echo "Warnning: There need a argument after -am"
                exit
               fi
                 ;;
        -as )  ifSuffixrename=1
               shift
               if [[ $1 != -* && $1 ]]
               then
                Suffix=$1
               else
                echo "Warnning: There need a argument after -as"
                exit
               fi
                  ;;
        -ap )  ifPrefixrename=1
               shift
               if [[ $1 != -* && $1 ]]
               then
                Prefix=$1
               else
                echo "Warnning: There need a argument after -ap"
               exit
               fi
                  ;;
        -bp ) 
	       ifBatchprocessing=1
               shift
               if [[ $1 != -* && $1 ]]
               then
                Batchprocessing=$1
               else
                echo "Warnning: There need a argument after -bp"
                exit
               fi
               ;;
        h )    usage
               exit
               ;;
        * )    usage
               exit 
    esac
    shift
done
#判断参数完整性 并执行相应命令
#保证所有的已选参数都被执行到
if [[ $ifBatchprocessing ]]
then
    batch_process $Batchprocessing
fi
if [[ $ifcompqua && $quality && $filename ]]
then
    compress_quality $quality $filename
fi
if [[ $ifcompredis &&  $compressratio && $filename ]]
then
    compress_dis $compressratio $filename
fi
if [[ $iftextwatermark && $filename && $textcontent ]]
then
    add_watermark $filename $textcontent
fi
if [[ $ifchangeformat && $filename ]]
then
    change_format $filename
fi
if [[ $ifSuffixrename && $filename && $Suffix ]]
then
    add_suffix $filename $Suffix
fi
if [[ $ifPrefixrename && $filename && $Prefix ]]
then
    add_prefix $filename $Prefix
fi
