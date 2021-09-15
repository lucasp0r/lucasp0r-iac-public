#!/bin/bash

# Shell script realizar a configuração de todos os profile no aws config para a Hub
# Para funcionamento a conta deve ter apenas um sso configurado Payer Account da Hub
# 

#./configure.sh <profile >

echo ""
echo "#############################################"
echo "#### iniciando script                      ###"
echo "#############################################"
echo ""
echo ""
STARTTIME=$(date +%s)

################################################################################
# GERANDO ARQUIVO DE USUÁRIOS AIM EXISTENTES
################################################################################

SSO_PROFILE="AdministratorAccess"

mkdir resultado

##HUB
aws organizations list-accounts --profile $1 --output json > resultado/organization.json
echo "" >> ~/.aws/config
jq -c '.Accounts[]' resultado/organization.json | while read item; do

    ACCOUNT_ID_ORIG=$(echo $item | jq '.Id')
    ACCOUNT_NAME_ORIG=$(echo $item | jq '.Name')

    ACCOUNT_NAME=$(echo $ACCOUNT_NAME_ORIG | tr -d \")
    ACCOUNT_ID=$(echo $ACCOUNT_ID_ORIG | tr -d \")

    echo "[profile $ACCOUNT_NAME]" >> ~/.aws/config
    echo "sso_start_url = https://.awsapps.com/start" >> ~/.aws/config

    echo "sso_region = us-east-1" >> ~/.aws/config
    echo "sso_account_id = $ACCOUNT_ID" >> ~/.aws/config
    echo "sso_role_name = $SSO_PROFILE" >> ~/.aws/config
    
    echo "output = yaml" >> ~/.aws/config
    echo "" >> ~/.aws/config
    echo "" >> ~/.aws/config 

done

echo ""
echo "#############################################"
echo "#### Termino script                      ###"
echo "#############################################"
echo ""
echo ""

rm -rf resultado/

ENDTIME=$(date +%s)
secs=$(($ENDTIME - $STARTTIME))
printf 'Elapsed Time %dh:%dm:%ds\n' $(($secs / 3600)) $(($secs % 3600 / 60)) $(($secs % 60))
echo ""