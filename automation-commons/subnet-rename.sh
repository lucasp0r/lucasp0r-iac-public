#!/bin/bash

# Shell script para realizar o rename das subnet para um determinado padrão.
# 

#./execute.sh <profile r> <sso_profile> <padrao-subnet-private> <padrao-subnet-publica>


echo ""
echo "#############################################"
echo "#### iniciando script                     ###"
echo "#############################################"
echo ""
STARTTIME=$(date +%s)

PROFILE_PAYER_ACCOUNT=$1
SSO_PROFILE=$2
SSO_START_URL=$3


mkdir resultado
mkdir -p resultado/vpc

aws organizations list-accounts --profile $PROFILE_PAYER_ACCOUNT --output json > resultado/aws_accounts.json

ACCOUNTS_ARRAY=("Audit" "Log Archive" "Master")

jq -c '.Accounts[]' resultado/aws_accounts.json | while read item; do

    ACCOUNT_ID_ORIG=$(echo $item | jq '.Id')
    ACCOUNT_NAME_ORIG=$(echo $item | jq '.Name')

    ACCOUNT_NAME=$(echo $ACCOUNT_NAME_ORIG | tr -d \")
    ACCOUNT_ID=$(echo $ACCOUNT_ID_ORIG | tr -d \")

    echo "" >> ~/.aws/config 
    if [[ ! " ${ACCOUNTS_ARRAY[@]} " =~ " ${ACCOUNT_NAME} " ]]; then
        echo
        echo "Verificando conta $ACCOUNT_NAME"
        echo

        echo "[profile $ACCOUNT_NAME]" >> ~/.aws/config
        echo "sso_start_url = ${SSO_START_URL}" >> ~/.aws/config

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

                echo "###VPC ID: $AWS_VPC"
                echo ""

                ################################################################################
                # RECUPERANDO DAS SUBNETS PÚBLICAS -FAIXA 172
                ################################################################################
                AWS_PUBLIC_SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$AWS_VPC --profile $ACCOUNT_NAME --output json | jq -r '.Subnets[] | select(.CidrBlock | startswith("172") )' | jq .SubnetId | tr -d \")
                PUB_SUBNETS=$(jq -ncR '[inputs]' <<<"$AWS_PUBLIC_SUBNETS")

                bkpIFS="$IFS"
                IFS=',()][' read -r -a subnets_pub <<<$PUB_SUBNETS
                IFS="$bkpIFS"
                
                for spub in "${subnets_pub[@]}"; do 
                    if [ ! -z "$spub" ] 
                    then
                        subnet=$(echo $spub | tr -d \")
                        echo "Ajustando subnet pública $subnet"
                        aws ec2 describe-subnets --subnet-id $subnet --profile $ACCOUNT_NAME --output json > resultado/aws_accounts_subnet-${subnet}.json
                        AVAILABILITY_ZONE=$(cat resultado/aws_accounts_subnet-${subnet}.json | jq -r '.Subnets[].AvailabilityZone')
                        NOME_ATUAL=$(cat resultado/aws_accounts_subnet-${subnet}.json | jq -r '.Subnets[]' | jq '.Tags[]|select(.Key=="Name").Value')
                        echo "Zona da subnet pública: $AVAILABILITY_ZONE"
                        echo "Nome atual da subnet pública: $NOME_ATUAL"
                        echo
                        if [[ "$AVAILABILITY_ZONE" == "sa-east-1a" || "$AVAILABILITY_ZONE" == "us-east-1a" ]]; then
                            aws ec2 create-tags --resource $subnet --tags Key=Name,Value=pub-a --profile $ACCOUNT_NAME
                        elif  [[ "$AVAILABILITY_ZONE" == "sa-east-1b" || "$AVAILABILITY_ZONE" == "us-east-1b" ]]; then
                            aws ec2 create-tags --resource $subnet --tags Key=Name,Value=pub-b --profile $ACCOUNT_NAME
                        elif  [[ "$AVAILABILITY_ZONE" == "sa-east-1c" || "$AVAILABILITY_ZONE" == "us-east-1c" ]]; then
                            aws ec2 create-tags --resource $subnet --tags Key=Name,Value=pub-c --profile $ACCOUNT_NAME
                        fi
                        
                        # aws ec2 describe-subnets --subnet-id $subnet --profile $ACCOUNT_NAME --output json | jq -r '.Subnets[]' | jq '.Tags[]|select(.Key=="Name").Value'
                    fi
                done

                ################################################################################
                # RECUPERANDO DAS SUBNETS PRIVADA -FAIXA 100
                ################################################################################
                # echo "#### Recuperando informações das subnets privadas - faixa 100 #####"
                AWS_PRIVATE_SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$AWS_VPC --profile $ACCOUNT_NAME --output json | jq -r '.Subnets[] | select(.CidrBlock | startswith("100") )' | jq .SubnetId | tr -d \")
                PRV_SUBNETS=$(jq -ncR '[inputs]' <<<"$AWS_PRIVATE_SUBNETS")
                # echo "Subnet privadas: $PRV_SUBNETS"

                bkpIFS="$IFS"
                IFS=',()][' read -r -a subnets_prv <<<$PRV_SUBNETS
                IFS="$bkpIFS"
                
                for sprv in "${subnets_prv[@]}"; do 
                    if [ ! -z "$sprv" ] 
                    then
                        subnet=$(echo $sprv | tr -d \")
                        echo "Ajustando subnet privadas $subnet"
                        aws ec2 describe-subnets --subnet-id $subnet --profile $ACCOUNT_NAME --output json > resultado/aws_accounts_subnet-${subnet}.json
                        AVAILABILITY_ZONE=$(cat resultado/aws_accounts_subnet-${subnet}.json | jq -r '.Subnets[].AvailabilityZone')
                        NOME_ATUAL=$(cat resultado/aws_accounts_subnet-${subnet}.json | jq -r '.Subnets[]' | jq '.Tags[]|select(.Key=="Name").Value')
                        echo "Zona da subnet privada: $AVAILABILITY_ZONE"
                        echo "Nome atual da subnet privada: $NOME_ATUAL"
                        echo
                        if [[ "$AVAILABILITY_ZONE" == "sa-east-1a" || "$AVAILABILITY_ZONE" == "us-east-1a" ]]; then
                            aws ec2 create-tags --resource $subnet --tags Key=Name,Value=prv-a --profile $ACCOUNT_NAME
                        elif  [[ "$AVAILABILITY_ZONE" == "sa-east-1b" || "$AVAILABILITY_ZONE" == "us-east-1b" ]]; then
                            aws ec2 create-tags --resource $subnet --tags Key=Name,Value=prv-b --profile $ACCOUNT_NAME
                        elif  [[ "$AVAILABILITY_ZONE" == "sa-east-1c" || "$AVAILABILITY_ZONE" == "us-east-1c" ]]; then
                            aws ec2 create-tags --resource $subnet --tags Key=Name,Value=prv-c --profile $ACCOUNT_NAME
                        fi
                        
                        # aws ec2 describe-subnets --subnet-id $subnet --profile $ACCOUNT_NAME --output json | jq -r '.Subnets[]' | jq '.Tags[]|select(.Key=="Name").Value'
                    fi
                done
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
