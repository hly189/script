#! /bin/bash

display_usage(){
	echo -e "\nExample Usage:\n$0 us-west-2 \n" 
	}

if [ $# -lt 1 ]  
then
	display_usage
	exit 1
fi

REGION=$1 
aws ec2 describe-instance-status --region $REGION | grep -i "InstanceId" | cut -d ":" -f 2

echo Which instance do you want to termninate?
read INSTANCE_ID


while read line
do
    vol[ $i ]="$line"
    #echo ${vol[$i]}
    i=$[$i+1]
done < <(aws ec2 describe-instances --region us-west-2 --instance $INSTANCE_ID | awk '/VolumeId/{gsub(/[",]+/, "", $2); print $2}')


aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID

sleep 120

i=0
while [ $i -lt 2 ]
do 
	aws ec2 delete-volume --region $REGION --volume-id ${vol[$i]}
	#echo ${vol[$i]}
	 i=$[$i+1]
done 
