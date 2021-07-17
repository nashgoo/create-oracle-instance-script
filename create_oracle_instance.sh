#!/bin/bash

# 想要新建的实例名称
INSTANCE_NAME='arm-jp'
# 可用区域
AVAILABILITY_DOMAIN='ULPB:AP-TOKYO-1-AD-1'
# 镜像ID
IMAGE_ID='ocid1.image.oc1.ap-tokyo-1.aaaaaaaa3aezbaykt4tizbvwd72ljzgcxc3cbjqofe3rp7n475l5wja6jbga'
# 子网ID
SUBNET_ID='ocid1.subnet.oc1.ap-tokyo-1.aaaaaaaaxerzk4vthhrhia73bwttm3tyawvixtxcbtkzfs2iurgsjywtwhya'
# 实例机型
SHAPE='VM.Standard.A1.Flex'
# CPU数
OCPUS=4
# 内存数GB
MEMORY_SIZE=24
# 启动硬盘空间GB
BOOT_VOL_SIZE=100
# SSH认证公钥
SSH_AUTH_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEGO+oahWChTdSzRpSGzhz0mTxxHDdyltqx6OmIlqLKacK6PEiuqJVDRzgvqPK279ZlMPxwRbtevN9UCDf2icx+sbBVW7wHr9eTWCN74y0luepma3AWjzx7fNfCvXxFRQqr55zTTkswOs7wzYO+htlmZO44cDAsDEx8t0Lo4Ce8MMTPb5XgwPv3bLfQHwCTtYp/XGZkv2+YSfBMqtF9yzxhjF3hFmA9foe8ZiQEOyRMR9sWBEY8/q6FdlRmFztLlKiHuxlV5XzMS1874NxjiRpA4L8X+lH6uzdjottLbJnzZ8z7zgXAuARe+nlo9L5XbzdkdCl3iTKEzIrQEWJKIHj angelsky11@angelsky11-pc'

#server酱开关，0为关闭，1为server酱，2为telegram
NOTIFICATION=0
#server酱参数
SERVERCHAN_KEY='YOUR_SERVERCHAN_KEY'
#telegram参数
BOT_TOKEN='1863458657:AAFz-j4pkH_kXht1EPKNiC1pMdgfzhlJoNU'
USERID=636446790

# 此行以下不用修改

option="${1}"
case $option in
	-c) 
		CONFIG_FILE="${2}"
		;;
	*)
		CONFIG_FILE='/root/.oci/config'
		;;
esac

userId=$(oci iam user list --config-file $CONFIG_FILE | jq -r '.[][0]."id"')
compartmentId=$(oci iam user list --config-file $CONFIG_FILE | jq -r '.[][0]."compartment-id"')

echo -e '*****************************************************************'
echo -e '***************************** START *****************************'
echo -e '*****************************************************************'

#定义主进程
function main {

	oci compute instance launch --availability-domain $AVAILABILITY_DOMAIN --image-id $IMAGE_ID --subnet-id $SUBNET_ID --shape $SHAPE --assign-public-ip true --metadata '{"ssh_authorized_keys": "'"${SSH_AUTH_KEY}"'"}' --compartment-id $compartmentId --shape-config '{"ocpus":'$OCPUS',"memory_in_gbs":'$MEMORY_SIZE',"boot_volume_size_in_gbs":'$BOOT_VOL_SIZE'}' --display-name $INSTANCE_NAME --config-file $CONFIG_FILE > res.json 2>&1
	
	sed -i '1d' res.json
	
	local responseCode=$(cat res.json | jq .status)
	
	if [ $responseCode = 200 ]
		then
			echo -e '==== create successed ===='
			# 发送通知
			if [ $NOTIFICATION != 0 ]
			then
				text="实例已新建成功"
				desp="您的位于${AVAILABILITY_DOMAIN}的甲骨文实例已创建成功！"
				notification "${text}" "${desp}"
			fi
	else
			echo -e '==== create failed ===='
	fi
	
	rm res.json -rf

}

# 定义函数发送通知
function notification {
	case $NOTIFICATION in 
		1)
			# serverchen通知
			local json=$(curl -s https://sc.ftqq.com/$SERVERCHAN_KEY.send --data-urlencode "text=$1" --data-urlencode "desp=$2")
			errno=$(echo $json | jq .errno)
			errmsg=$(echo $json | jq .errmsg)
			if [ $errno = 0 ]
			then
				echo -e 'notice send success'
			else
				echo -e 'notice send faild'
				echo -e "the error message is ${errmsg}"
			fi
			;;
		2)
			# telegram通知
			curl -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=${USERID}&text=${2}"
			;;
		*)
			exit 1
			;;
	esac
}

main
	
echo -e '*****************************************************************'
echo -e '****************************** END ******************************'
echo -e '*****************************************************************'

exit 0
