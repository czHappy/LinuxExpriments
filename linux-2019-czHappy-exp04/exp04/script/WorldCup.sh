#!/bin/bash

function usage
{
echo "Useage: WorldCup.sh [-ls <num>] [-gt <num>] [-r <num>] [-r] [-p] [-n] [-a]"
echo "command	args		description"
echo "-ls	<number>	年龄小于x的球员数量以及百分比"
echo "-gt	<number>	年龄大于x的球员数量以及百分比"
echo "-r	<n1><n2>	年龄在x,y之间的球员数量以及百分比"
echo "-p			场上不同位置球员的数量以及百分比"
echo "-n			名字最长的球员和名字最短的球员"
echo "-a			年龄最大的球员和年龄最小的球员"
echo "-h                        显示帮助信息"

echo ""

}
function less_than
{
awk -F '\t' 'BEGIN{x=0} {if(NR > 1 && $6 < '$1'){x++}} END{printf("年龄小于%s的球员人数有%s个,占比%.8f%\n",'$1',x,x*100/(NR-1))}' worldcupplayerinfo.tsv
}
function greater_than
{
awk -F '\t' 'BEGIN{x=0} {if(NR > 1 && $6 > '$1'){x++}} END{printf("年龄大于%s的球员人数有%s个,占比%.8f%\n",'$1',x,x*100/(NR-1))}' worldcupplayerinfo.tsv
}
function range
{
awk -F '\t' 'BEGIN{x=0} {if(NR > 1 && $6 >= '$1' && $6 <= '$2'){x++}} END{printf("年龄大于%s岁且小于%s岁的球员人数有%s个,占比%.8f%\n",'$1','$2',x,x*100/(NR-1))}' worldcupplayerinfo.tsv
}

function position
{
POSITIONS=$(awk -F '\t' '{print $5}' worldcupplayerinfo.tsv) 
declare -A dic
all=0
for line in $POSITIONS;
do
#去除第一行的影响
#!dic[*]指的是key dic[*]指的是值
if [[ $line != 'Position'  ]];then
#echo "line = $line........................................"
	(( all++ ))
#	if [[ !${dic[$line]} ]];then
	((dic[$line]++))
#	else
#		dis[$line]=0
#	fi
fi		
done
for key in ${!dic[@]};do
	if [[ ${dic[$key]} ]]; then
	echo "$key : ${dic[$key]} 所占比例为:" $(awk 'BEGIN{printf "%.2f",'${dic[$key]}*100/$all'}')'%'
	fi
done
}
function name
{
NAMES=$( awk -F '\t' '{print $9}' worldcupplayerinfo.tsv)
max=0
min=100000
longest=''
shortest=''
CNT=0
for name in $NAMES
do
#echo "name = $name......................."
	let CNT+=1	
	if [[  ${#name} -gt $max ]]
	then
		max=${#name}
		longest=$name
	fi		
	if [[ ${#name} -lt $min ]]
	then
		minlength=${#name}	
		shortest=$name
	fi
done 
echo ''
echo '名字最长的球员是：'$longest
echo '名字最短的球员是：'$shortest
}

function age
{
declare -a AGE
declare -a NAME
AGE=$( awk -F '\t' 'NR>1{print $6}' worldcupplayerinfo.tsv)
NAME=$( awk -F '\t' 'NR>1{print $9}' worldcupplayerinfo.tsv)
max=0
min=100000
oldest=''
youngest=''
CNT=2
for age in $AGE
do
if [[ $age -gt $max ]]; then
	max=$age
	oldest=$(awk -F '\t' 'NR=='$[$CNT+1]' {print $9}' worldcupplayerinfo.tsv)
fi
if [[ $age -lt $min ]]; then
	min=$age
	youngest=$(awk -F '\t' 'NR=='$[$CNT+1]' {print $9}' worldcupplayerinfo.tsv)
fi
let CNT+=1
done
echo '年龄最大的球员是：'$oldest $max
echo '年龄最小的球员是：'$youngest  $min

}

if [ $# == 0 ];then
	usage
	exit
fi
while [ "$1" != "" ]; do
    case $1 in
	-ls )	ifls=1
		shift
		if [[ $1 != -* && $1 ]];then
			lsx=$1
		else
			echo "There need a parameter after -ls"
			exit
		fi
		;;

	-gt )   ifgt=1
		shift
		if [[ $1 != -* && $1 ]];then
			gtx=$1
		else
			echo "There need a parameter after -gt"
			exit
		fi
		;;

	-r )    ifr=1
		shift
		if [[ $1 != -* && $1 ]];then
			r1=$1
		else
			echo "There need two parameter after -r"
			exit
		fi
		shift
		if [[ $1 != -* && $1 ]]; then
			r2=$1
		else
			echo "There need two parameter after -r"
			exit
		fi
		;;
	-p )    ifp=1
		;;

	-n )    ifn=1
		;;

	-a )    ifa=1
		;;

	-h )    usage
		exit
		;;
	* )     usage
		exit 
		;;
     esac
     shift
done

if [[ $ifls && $lsx ]]; then
	less_than $lsx
fi
if [[ $ifgt && $gtx ]]; then
	greater_than $gtx
fi
if [[ $ifr && $r1 && $r2 ]]; then
	range $r1 $r2
fi
if [[ $ifp ]] ;then
	position
fi
if [[ $ifn ]]; then
	name 
fi
if [[ $ifa ]] ;then
	age
fi	

