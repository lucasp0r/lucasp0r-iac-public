#!/bin/bash

# Shell script para realizar o rename das subnet da orange para um determinado padrão.
# 

#./execute.sh <profile> <sso_profile> <TAG_NAME> <TAG_VALUE>


echo ""
echo "#############################################"
echo "#### iniciando script                     ###"
echo "#############################################"
echo ""
STARTTIME=$(date +%s)

PROFILE_PAYER_ACCOUNT=$1
SSO_PROFILE=$2
TAG_NAME=$3
TAG_VALUE=$4

mkdir resultado
mkdir -p resultado/vpc/

aws organizations list-accounts --profile $PROFILE_PAYER_ACCOUNT --output json > resultado/aws_accounts.json

ACCOUNTS_ARRAY=("Master")

jq -c '.Accounts[]' resultado/aws_accounts.json | while read item; do

    ACCOUNT_ID_ORIG=$(echo $item | jq '.Id')
    ACCOUNT_NAME_ORIG=$(echo $item | jq '.Name')

    ACCOUNT_NAME=$(echo $ACCOUNT_NAME_ORIG | tr -d \")
    ACCOUNT_ID=$(echo $ACCOUNT_ID_ORIG | tr -d \")

    echo "" >> ~/.aws/config 
    if [[ ! " ${ACCOUNTS_ARRAY[@]} " =~ " ${ACCOUNT_NAME} " ]]; then
        echo
        echo "### Verificando conta $ACCOUNT_NAME"
        echo

        echo "[profile $ACCOUNT_NAME]" >> ~/.aws/config
        echo "sso_start_url = https://d-90676779f6.awsapps.com/start#/" >> ~/.aws/config

        if [[ $ACCOUNT_NAME == *"prd"* || $ACCOUNT_NAME == *"prod"* ]]; then
            echo "region = sa-east-1" >> ~/.aws/config
        else
            echo "region = us-east-1" >> ~/.aws/config
        fi
        
        echo "sso_region = us-east-1" >> ~/.aws/config
        echo "sso_account_id = $ACCOUNT_ID" >> ~/.aws/config
        echo "sso_role_name = $SSO_PROFILE" >> ~/.aws/config
        
        echo "output = yaml" >> ~/.aws/config
        echo "" >> ~/.aws/config
        echo "" >> ~/.aws/config 
        
        aws ec2 describe-vpcs --profile $ACCOUNT_NAME --output json > resultado/vpc/$ACCOUNT_NAME.json
        if [ $? -ne 0 ]
        then
            echo -e "Não foi possível conectar a conta $ACCOUNT_NAME."
        else
            AWS_VPC=$(cat resultado/vpc/$ACCOUNT_NAME.json | jq -r '.Vpcs[]' | jq .VpcId | tr -d \")
            if [[ $AWS_VPC ]]; then

                echo "VPC ID: $AWS_VPC"
                echo ""
                echo "Adicionando tag $TAG_NAME valor $TAG_VALUE a VPC"
                aws ec2 create-tags --resource $AWS_VPC --tags Key=$TAG_NAME,Value=$TAG_VALUE --profile $ACCOUNT_NAME
            else
                echo "Account sem VPC definida"
            fi
        fi
    fi
done

rm -rf resultado/

echo ""
echo "#############################################"
echo "#### Termino script                      ###"
echo "#############################################"
echo ""
echo ""

ENDTIME=$(date +%s)
secs=$(($ENDTIME - $STARTTIME))
printf 'Elapsed Time %dh:%dm:%ds\n' $(($secs / 3600)) $(($secs % 3600 / 60)) $(($secs % 60))
echo ""
