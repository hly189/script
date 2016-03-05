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

aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID
