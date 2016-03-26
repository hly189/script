#! /bin/bash
set -x
display_usage(){
        echo -e "\nExample Usage:\n$0 awl01 us-west-2 \n"
        }

if [ $# -lt 2 ]
then
	display_usage
	exit 1
fi

AZ=$1
SUBNET=
SECURITY_GROUP=
INVENTORY_GROUP=
WEIGHT=
AMI=
REGION=

echo $AZ
case $AZ in
	"us-east-1b")
		SUBNET="subnet-2a3b5d47"
		SECURITY_GROUP="sg-f7d52998"
		INVENTORY_GROUP="collector-use1"
		WEIGHT=100
		AMI="ami-fce3c696"
		REGION="us-east-1"
		;;
	"us-east-1d")
                SUBNET="subnet-e6385e8b"
                SECURITY_GROUP="sg-f7d52998"
                INVENTORY_GROUP="collector-use1"
		WEIGHT=100
		AMI="ami-fce3c696"
		REGION="us-east-1"
		;;
	"us-east-1e")
                SUBNET="subnet-07395f6a"
                SECURITY_GROUP=sg-f7d52998
                INVENTORY_GROUP=collector-use1
		WEIGHT=100
		AMI=ami-fce3c696
		REGION=us-east-1
		;;
	"us-west-2a")
                SUBNET="subnet-4ca04224"
                SECURITY_GROUP=sg-9a9fddfe
                INVENTORY_GROUP=collector-usw2
		WEIGHT=60
		AMI=ami-9abea4fb
		REGION=us-west-2
		;;
	"us-west-2b")
    		SUBNET="subnet-4ca04224"
                SECURITY_GROUP=sg-9a9fddfe
                INVENTORY_GROUP=collector-usw2
                WEIGHT=60
                AMI=ami-9abea4fb
                REGION=us-west-2
                ;;
	"us-west-2c")
                SUBNET="subnet-e6a0428e"
                SECURITY_GROUP=sg-9a9fddfe
                INVENTORY_GROUP=collector-usw2
		WEIGHT=60
		AMI=ami-9abea4fb
		REGION=us-west-2
		;;
esac

echo $SUBNET $SECURITY_GROUP $INVENTORY_GROUP $AMI $REGION

read

start=$(ec2-run-instances --region $REGION $AMI -n 1 -z $AZ -K hoa_ly  -b "/dev/sdb=ephemeral0")

if [ $? != 0 ] ; then
        echo "Machine did not start" 1>&2
        exit 1
fi

INSTANCE=$(echo "$start" | awk '/^INSTANCE/ {print $2}')

echo "Name of the role that you want to create: "
read ROLE_NAME

sudo ansible-galaxy init /etc/ansible/ROLE_NAME
