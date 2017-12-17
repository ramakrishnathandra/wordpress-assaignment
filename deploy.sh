#!/bin/bash
set -e

function help()
{
    echo ""
    echo "usage: deploy.sh -x [os] -i [keyname] -N [ec2 instance name] -I [ubuntu 14.04 amiid] -f [ec2 instance type] -e [elasticip] -g [security group] -s [subnetid] -u [SITE url]"
    echo "-x aws os"
    echo "-i aws keyname"
    echo "-N aws name of the ec2 instance"
    echo "-I aws ubuntu 14.04 amiid"
    echo "-f aws instance type"
    echo "-e aws elasticip"
    echo "-g aws security group"
    echo "-s aws subnet id to launch ec2 in vpc"
    echo "-u external site url"
    echo "-h help"
}

OS="ubuntu"
KEYNAME="test.pem"
EC2NAME="cleo-wordpress"
AMIID="ami-25cf1c5d"
EC2TYPE="t2.small"
EIP="52.24.103.35"
SECURITYGROUP="sg-28cd7c55"
SUBNETID="subnet-f4c46dbc"
SITEURL=""

while getopts "x:i:N:I:f:e:g:s:u:h" opt
do
    case $opt in
        h)
            help
            exit 0
            ;;
        [?])
            echo "Invalid option"
            help
            exit -1
            ;;
        x)
            OS=$OPTARG;;
        i)
            KEYNAME=$OPTARG;;
        N)
            EC2NAME=$OPTARG;;
        I)
            AMIID=$OPTARG;;
        f)
            EC2TYPE=$_OPTARG;;
        e)
            EIP=$OPTARG;;
        g)
            SECURITYGROUP=$OPTARG;;
        s)
            SUBNETID=$OPTARG;;
        u)
            SITEURL=$OPTARG;;
    esac
done


if [ -z "$SITEURL" ];
then
    SITEURL=$EIP
fi

sed -i '/"siteurl"/c\"siteurl": "'$SITEURL'"' data_bags/wordpress/wordpress.json
knife data bag create wordpress
knife data bag from file wordpress data_bags/wordpress/wordpress.json
knife cookbook upload wordpress --force

knife ec2 server create -x $OS -i $KEYNAME -N $EC2NAME -I $AMIID  -f $EC2TYPE --node-ssl-verify-mode none -r 'recipe[wordpress]' --associate-eip $EIP -g $SECURITYGROUP --subnet $SUBNETID  --server-connect-attribute public_ip_address –environment staging
