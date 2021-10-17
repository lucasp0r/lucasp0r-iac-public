#!/bin/bash

# Shell script para realizar a criação das hosted zones privadas para a Hub
# Para funcionamento a conta deve ter apenas um sso configurado Master Account e a Transit correspondente
# 

#./Create_PHZ_Hub.sh <profile -payer (master)> <profile -hub (transit)>

echo ""
echo "#############################################"
echo "#### Inciando script                      ###"
echo "#############################################"
echo ""
STARTTIME=$(date +%s)

################################################################################
# GERANDO ARQUIVO DE USUÁRIOS AIM EXISTENTES
################################################################################

mkdir resultado

PROFILE_HUB_MASTER_ACCOUNT=$1
PROFILE_HUB_TRANSIT=$2
VPC_CENTRAL_QA=$3
DOMINIO_BASE_QA=$4
VPC_CENTRAL_DEV=$5
DOMINIO_BASE_DEV=$6
VPC_CENTRAL_PRD=$7
DOMINIO_BASE_PRD=$8
VPC_CENTRAL_SBOX=$9
DOMINIO_BASE_SBOX=$10

aws organizations list-accounts --profile $PROFILE_HUB_MASTER_ACCOUNT --output json > resultado/hub_organization.json

#Contas para remover da execução
ACCOUNTS_ARRAY=("")

jq -c '.Accounts[]' resultado/hub_organization.json | while read item; do
    ACCOUNT_ID_ORIG=$(echo $item | jq '.Id')
    ACCOUNT_NAME_ORIG=$(echo $item | jq '.Name')

    ACCOUNT_NAME=$(echo $ACCOUNT_NAME_ORIG | tr -d \")
    ACCOUNT_ID=$(echo $ACCOUNT_ID_ORIG | tr -d \")

    echo "" >> ~/.aws/config 
    if [[ ! " ${ACCOUNTS_ARRAY[@]} " =~ " ${ACCOUNT_NAME} " ]]; then
        echo
        echo "Configurando conta $ACCOUNT_NAME"
        echo

        echo "[profile $ACCOUNT_NAME]" >> ~/.aws/config
        echo "sso_start_url = https://.awsapps.com/start/#/" >> ~/.aws/config

        if [[ ! $ACCOUNT_NAME == *"-prod"* ]] && [[ $ACCOUNT_NAME == *"prd"* || $ACCOUNT_NAME == *"prod"* ]]; then
            echo "region = sa-east-1" >> ~/.aws/config
        else
            echo "region = us-east-1" >> ~/.aws/config
        fi
        
        echo "sso_region = us-east-1" >> ~/.aws/config
        echo "sso_account_id = $ACCOUNT_ID" >> ~/.aws/config
        echo "sso_role_name = AdministratorAccess" >> ~/.aws/config
        
        echo "output = yaml" >> ~/.aws/config
        echo "" >> ~/.aws/config
        echo "" >> ~/.aws/config 

        DOMINIO_BASE=""
        VPC_CENTRAL=""
        REGIAO=""

        if [[ "$ACCOUNT_NAME" == *"dev" || "$ACCOUNT_NAME" == *"lab" || "$ACCOUNT_NAME" == *"sandbox"* ]]; then
            DOMINIO_BASE=${DOMINIO_BASE_DEV}
            VPC_CENTRAL=${VPC_CENTRAL_DEV}
            REGIAO=us-east-1
        
        elif [[ "$ACCOUNT_NAME" == *"qa" || "$ACCOUNT_NAME" == *"staging"* || "$ACCOUNT_NAME" == *"stg" || "$ACCOUNT_NAME" == *"poc" ]]; then
            DOMINIO_BASE=${DOMINIO_BASE_QA}
            VPC_CENTRAL=${VPC_CENTRAL_QA}
            REGIAO=us-east-1

        elif [[ "$ACCOUNT_NAME" == *"-products"* && ( "$ACCOUNT_NAME" == *"prd"* || "$ACCOUNT_NAME" == *"prod" ) ]]; then
            DOMINIO_BASE=${DOMINIO_BASE_PRD}
            VPC_CENTRAL=${VPC_CENTRAL_PRD}
            REGIAO=sa-east-1

        elif [[ "$ACCOUNT_NAME" == *"-prod"* && ( "$ACCOUNT_NAME" == *"prd"* || "$ACCOUNT_NAME" == *"prod"* ) ]]; then
            DOMINIO_BASE=${DOMINIO_BASE_PRD}
            VPC_CENTRAL=${VPC_CENTRAL_PRD}
            REGIAO=sa-east-1 

        elif [[ "$ACCOUNT_NAME" == *"prd"* || "$ACCOUNT_NAME" == *"prod"* ]]; then
            DOMINIO_BASE=${DOMINIO_BASE_PRD}
            VPC_CENTRAL=${VPC_CENTRAL_PRD}
            REGIAO=sa-east-1         
        fi        

        if [[ $DOMINIO_BASE ]]; then 

            PROJETO_NOME=$(echo $ACCOUNT_NAME | sed 's/-//' | sed 's/-prd//' | sed 's/-prod//' | sed 's/-develop//' | sed 's/-dev//' | sed 's/-qa//' | sed 's/-stg//' | sed 's/-staging//' | sed 's/-sandbox//')

            PHZ_REF=$(date +%s)

            aws route53 list-hosted-zones --output json --profile ${ACCOUNT_NAME} >> resultado/"${ACCOUNT_NAME}_hostedzone.json"
            if [ $? -ne 0 ]; then
                echo "ERRORRRRRRRRRRRRRRRRRRRRRRR"
                echo "Conta sem acesso $ACCOUNT_NAME" >> hub_contas_sem_acesso.txt
            else 
                EXIST_PRIVATE_ZONE=""
                shopt -s lastpipe

                jq -c '.HostedZones[]' resultado/${ACCOUNT_NAME}_hostedzone.json | while read item; do
                    PRIVATE_ZONE=$(echo $item | jq '.Config.PrivateZone')
                    if [[ "$PRIVATE_ZONE" == "true" ]]; then
                        EXIST_PRIVATE_ZONE="true"
                        echo "Conta previamente configurada $ACCOUNT_NAME" >> hub_contas_previamente_configuradas.txt
                    fi

                done
                
                if [[ "$EXIST_PRIVATE_ZONE" != "true" ]]; then
                    
                    echo "Nome da conta: $ACCOUNT_NAME" >> hub_contas_configuradas.txt
                    echo "Nome do projeto: $PROJETO_NOME" >> hub_contas_configuradas.txt
                    echo "Nome completo PHZ: ${PROJETO_NOME}.${DOMINIO_BASE}" >> hub_contas_configuradas.txt
                    echo "VPC Central $VPC_CENTRAL" >> hub_contas_configuradas.txt

                    PROJETO_VPC_ID=$(aws ec2 describe-vpcs --output json --profile $ACCOUNT_NAME | jq -r '.Vpcs[0].VpcId')
                    echo "VPC do Projeto $PROJETO_VPC_ID" >> hub_contas_configuradas.txt
                    echo "" >> hub_contas_configuradas.txt
                    echo "" >> hub_contas_configuradas.txt

                    echo "Criando Private Hosted Zone, REF: ${PHZ_REF}"
                    PHZ_ID=$(aws route53 create-hosted-zone --vpc VPCRegion=${REGIAO},VPCId=${PROJETO_VPC_ID} --caller-reference ${PHZ_REF} --name ${PROJETO_NOME}.${DOMINIO_BASE} --hosted-zone-config PrivateZone=true --region ${REGIAO} --output json --profile $ACCOUNT_NAME | jq -r '.HostedZone.Id')

                    echo "Private Hosted Zone criado, ID: ${PHZ_ID}"

                    echo "Criando Associação com a VPC Central."
                    aws route53 create-vpc-association-authorization --hosted-zone-id ${PHZ_ID} --vpc VPCRegion=${REGIAO},VPCId=${VPC_CENTRAL} --region ${REGIAO} --output json --profile $ACCOUNT_NAME

                    echo "Autorizando a Associação com a VPC Central."
                    aws route53 associate-vpc-with-hosted-zone --hosted-zone-id ${PHZ_ID} --vpc VPCRegion=${REGIAO},VPCId=${VPC_CENTRAL} --region ${REGIAO} --output json --profile ${PROFILE_HUB_TRANSIT}
                fi
            fi
        else 
            echo "Conta não configurada: $ACCOUNT_NAME" >> hub_contas_nao_configuradas.txt
            echo
        fi

    fi

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
