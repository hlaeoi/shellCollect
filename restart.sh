#!/bin/sh
#根据进程名杀死进程
arg_debug="0";
arg_stop="0"
arg_restart="0"
arg_start="0"
debug_default_port="8889";
parse_arguments() {
	local helperKey="";
	local helperValue="";
	local current="";

	for arg in $*  
	do  
		if [[ $arg == "" ]]
		then
			continue;
		fi
		if [[ !($arg =~ "--") ]]
		then
			JARNAMELIST=$arg;
			continue;
		fi
		current=$arg;
		helperKey=${current#*--};
		helperKey=${helperKey%%=*};
		helperKey=$(echo "$helperKey" | tr '-' '_');
		helperValue=${current#*=};
		if [ "$helperValue" == "$current" ]; then
			helperValue="1";
		fi
		#echo "eval arg_$helperKey=\"$helperValue\"";

		eval "arg_$helperKey=\"$helperValue\"";
		shift
	done
}
if [ $# -lt 1 ]
then
        JARNAMELIST=`ls *.jar`
else
	#echo ${@};
        parse_arguments ${@};
fi
#echo $JARNAMELIST
#echo $arg_debug
if [ "$arg_debug" == "1" ]; then
	arg_debug=$debug_default_port;
	#echo $arg_debug;
fi
if [ "$arg_restart" == "1" ]; then
	arg_stop="1";
	arg_start="1";
fi
for jarName in $JARNAMELIST;
do
	PROCESS=`ps -ef|grep $jarName|grep -v restart.sh|grep -v grep|grep -v PPID|awk '{ print $2}'`
	for i in $PROCESS
	do
		echo "Kill the $jarName process [ $i ]"
		if [ "$arg_stop" == "1" ]; then
			kill -9 $i
		fi
	done
	if [ "$arg_debug" != "0" ]; then
		nohup java -Xdebug -Xrunjdwp:transport=dt_socket,address=$arg_debug,server=y,suspend=y -Xms128m -Xmx256m -jar $jarName &
	else if [ "$arg_start" == "1" ]; then
		nohup java -Xms128m -Xmx256m -jar $jarName &
	fi
done
tail -200f nohup.out
