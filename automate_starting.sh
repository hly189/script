#! /bin/bash

# This script is used to run 3 machines at the same time

usage()
{
	cat << EOF
	usage: $0 -g parser -a parserapp 

	This script run the test1 or test2 over a machine.

	OPTIONS:
	-h help
	-g group such as parser, spliter, etc
	-a Applications such as parserapp, spliterapp, etc 
EOF
}

APP=
APP_SERVICE=

while getopts “hg:a:” OPTION
do
     case $OPTION in
         h|--help)
             usage
             exit 1
             ;;
         g|--group)
             APP=$OPTARG
             ;;
         a|--application)
             APP_SERVICE=$OPTARG
             ;;
	 ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $APP ]] || [[ -z $APP_SERVICE ]] 
then
     usage
     exit 1
fi

i=0
while read line
do
    array[ $i ]="$line"
    i=$[$i+1]
#replace locahost by you machine's host
done < <(cat $APP | cut -d " " -f 1) 

for index in "${!array[@]}"
do 
	length=$index
done

i=0
while [ $i -lt $[$length+1] ]
do
	j=0
	while [ $j -lt 3 ]; do
		#replace this line by your command 
		#ansible-playbook -i hosts playbook.yml -e"target=${array[i]}"
		echo ${array[i]} $APP $APP_SERVICE
		i=$[$i+1]
		if [[ $i -ge $[$length+1] ]]
		then
			break 
		fi
		j=$[$j+1]
	done
	if [[ $i -le $length ]]
	then
		echo "Do you want to continue? (yes/no)"
		read value
		if [[ $value == "no" || $value == "n" ]]
		then 
			break
		fi
	fi
done 


