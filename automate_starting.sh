#! /bin/bash

# This script is used to run 3 machines at the same time
i=0
while read line
do
    array[ $i ]="$line"
    i=$[$i+1]
#replace locahost by you machine's host
done < <(cat localhosts2 | cut -d " " -f 1) 

for index in "${!array[@]}"
do 
	length=$index
done

i=0
while [ $i -lt $[$length+1] ]
do
	j=0
	while [ $j -lt 3 ]; do
		#replace this playbook by your playbook, but the host should be {{ target }}  
		#ansible-playbook -i hosts playbook.yml -e"target=${array[i]}"
		echo ${array[i]}
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
		if [[ $value == "no" ]]
		then 
			break
		fi
	fi
done 


