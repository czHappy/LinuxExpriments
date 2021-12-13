#!/bin/bash

function usage
{
echo "Useage: logStatsProg.sh [-tsh <num>] [-tsi <num>] [-turl <num>] [-sc] [-t4xx <num>] [-urls <url> <n>]"
echo "command	args		description"
echo "-tsh	<number>	统计来源主机top x 和分别对应的总次数"
echo "-tsi	<number>	统计来源主机top x IP 和分别对应的总次数"
echo "-turl	<number>	统计最频繁被访问的URL top x"
echo "-sc			统计不同相应状态码的出现次数和对应百分比"
echo "-t4xx	<number>	统计不同4XX状态码对应的top x URL和对应出现总次数"
echo "-urls	<url><n>	给定URL输出top x访问来源主机"
echo ""

}
#查询主机
function top_source_host
{
#echo "number = $1"
#sort是默认从小到大的所以需要逆序
(sed -e '1d' web_log.tsv | awk -F '\t' '{a[$1]+=1} END {for(i in a) {print a[i],i}}' | sort -n -r | head -n $1)
}
#查询IP
function top_source_ip
{
 (sed -e '1d' web_log.tsv|awk -F '\t' '{if($1~/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/) print $1}'|awk '{a[$1]++} END {for(i in a){print i,a[i]}}'|sort -nr -k2|head -n $1)
}
#查询URL
function top_url
{
awk -F '\t' '{a[$5]+=1} END {for(i in a) {print i}}' web_log.tsv | sort -n -r | head -n $1
}
#查询状态码
function status_code
{
awk -F '\t'  'NR>1{a[$6]++} END {for(i in a) {ratio=100*a[i]/(NR-1); printf("%s, %.8f%, %s\n", i, ratio, a[i])}}' web_log.tsv 
}
#查询4xx状态码
function t4xx_sc
{
    #先把4xx状态码全部求出来
    a=$(sed -e '1d' web_log.tsv |awk -F '\t' '{if($6~/^4+/) a[$6]++} END {for(i in a) print i}')
    #对于每一个4xx，求其top x
    for i in $a
    do
        (sed -e '1d' web_log.tsv |awk -F '\t' '{if($6~/^'$i'/) a[$6][$5]++} END {for(i in a){for(j in a[i]){print i,j,a[i][j]}}}'|sort -nr -k3|head -n $1)
    done
}

function url_top_host
{
#awk -F '\t' '{if($5~/'$1'/) a[$5]+=1} END {for(i in a) {print i}}' web_log.tsv | sort -n -r | head -n $2
awk -F '\t' '{if($5=="'$1'") a[$1]++} END {for(i in a){print i,a[i]}}' web_log.tsv |sort -nr -k2|head -n  $2

}


if [ $# == 0 ];then
	usage
#	echo "无参数，跳出"
	exit
fi
#echo "here"
while [ "$1" != "" ]; do
 #   echo "incycle"
    case $1 in
	-tsh )	iftsh=1
		shift
		if [[ $1 != -* && $1 ]];then
			tshn=$1
		else
			echo "There need a parameter after -tsh"
			exit
		fi
		;;

	-tsi ) iftsi=1
		shift
		if [[ $1 != -* && $1 ]];then
			tsin=$1
		else
			echo "There need a parameter after -tsi"
			exit
		fi
		;;

	-turl ) ifturl=1
		shift
		if [[ $1 != -* && $1 ]];then
			turln=$1
		else
			echo "There need a parameter after -turl"
			exit
		fi
		;;

	-sc ) ifsc=1
		;;

	-t4xx ) ift4xx=1
		shift
		if [[ $1 != -* && $1 ]];then
			t4xxn=$1
		else
			echo "There need a parameter after -t4xx"
			exit
		fi
		;;

	-urls ) ifurls=1
		shift
		if [[ $1 != -* && $1 ]];then
			url=$1
		else
			echo "There need two parameter after -t4xx"
			exit
		fi
		shift
		if [[ $1 != -* && $1 ]];then
			urln=$1
		else
			echo "There need two parameter after -t4xx"
			exit
		fi

		;;

	-h ) usage
		exit
		;;
	* ) usage
		
		exit 
		;;
     esac
     shift
done

if [[ $iftsh && $tshn ]]; then
	top_source_host $tshn
fi
if [[ $iftsi && $tsin ]]; then
	top_source_ip $tsin
fi
if [[ $ifturl && $turln ]]; then
	top_url $turln
fi
if [[ $ifsc ]] ;then
	status_code 
fi
if [[ $ift4xx && $t4xxn ]]; then
	t4xx_sc $t4xxn
fi
if [[ $ifurls && $url && $urln ]] ;then
	url_top_host $url $urln
fi	
