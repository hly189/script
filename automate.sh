#! /bin/bash

# This script is used to run 3 machines at the same time
i=0
while read line
do
    array[ $i ]="$line"        
    i=$[$i+1]
#replace locahost by you machine's host
done < <(cat localhosts) 

length=$[${#array[@]}-1]

i=0
while [ $i -lt $length ]
do
	j=0
	while [ $j -lt 3 ]; do
		#replace this playbook by your playbook, but the host should be {{ target }}  
		ansible-playbook -i hosts playbook.yml -e"target=${array[i]}"
		i=$[$i+1]
		j=$[$j+1]
	done
	echo "Do you want to continue? (yes/no)"
	read value
	if [[ $value == "no" ]]
	then 
		break
	fi
done 

