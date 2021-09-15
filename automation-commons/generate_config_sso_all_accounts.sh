#!/bin/bash

# Shell script responsável configurar o sso para todas cloud accounts
# Para funcionamento a conta deve ter apenas um sso configurado Payer Account
# 

#./generate_data_all_accounts_user.sh <profile zuphub-payer>

echo ""
echo "#############################################"
echo "#### iniciando script                      ###"
echo "#############################################"
echo ""
echo ""

################################################################################
# GERANDO ARQUIVO DE USUÁRIOS AIM EXISTENTES
################################################################################

mkdir resultado

aws configservice list-aggregate-discovered-resources --resource-type AWS::IAM::User --filter Region=sa-east-1 --configuration-aggregator-name -org-all-accounts --profile $1 --output json > resultado/zuphub-users.json

ACCOUNTS_ARRAY=()

### Criando HEAD CSV
echo "AWS Account, Nome AWS Account, Usuário, Data de criação, Último Acesso (console), Acess Key 01, Acess Key 01 - Data última utilização, Acess Key 02, Acess Key 02 - Data última utilização" >> resultado.csv

jq -c '.ResourceIdentifiers[]' resultado/zuphub-users.json | while read item; do
    SourceAccountId=$(echo $item | jq '.SourceAccountId')
    ResourceName=$(echo $item | jq '.ResourceName' | tr -d \")
    if [[ ! " ${ACCOUNTS_ARRAY[@]} " =~ " ${SourceAccountId} " ]]; then

        ACCOUNT_ID=$(echo $SourceAccountId | tr -d \")
        echo "[profile $ACCOUNT_ID]" >> ~/.aws/config
        echo "sso_start_url = https://.awsapps.com/start" >> ~/.aws/config
        echo "sso_region = us-east-1" >> ~/.aws/config
        echo "sso_account_id = $ACCOUNT_ID" >> ~/.aws/config
        echo "sso_role_name = AdministratorAccess" >> ~/.aws/config
        echo "region = us-east-1" >> ~/.aws/config
        echo "output = yaml" >> ~/.aws/config
        echo "" >> ~/.aws/config
        echo "" >> ~/.aws/config

        ACCOUNT_ALIAS=$(aws iam list-account-aliases --profile $ACCOUNT_ID --output json | jq -r '.AccountAliases[]')
        if [[ $ACCOUNT_ALIAS ]]; then
        
            echo "Verificando usuario na conta $ACCOUNT_ID"
            ACCOUNT_DATA="$ACCOUNT_ID,$ACCOUNT_ALIAS,"
            USERS=$(aws iam list-users --profile $ACCOUNT_ID --output json)
        
            if [[ $USERS ]]; then
                echo "$USERS" > resultado/"${ACCOUNT_ID}_users".json
                # echo "$USERS"
                echo "**** Usuarios da conta: $ACCOUNT_ID " >> resultado/usuarios.txt
                echo "" >> resultado/usuarios.txt
                echo "$USERS" >> resultado/usuarios.txt
                echo "" >> resultado/usuarios.txt
                echo "" >> resultado/usuarios.txt

                jq -c '.Users[]' resultado/"${ACCOUNT_ID}_users".json | while read item; do
                    USERNAME=$(echo $item | jq '.UserName')
                    CREATEDATE=$(echo $item | jq '.CreateDate' | tr -d \")
                    PASSWORDLASTUSED=$(echo $item | jq '.PasswordLastUsed' | tr -d \")
                    if [[ "${PASSWORDLASTUSED}" == "null" ]]; then
                        PASSWORDLASTUSED=""
                    fi

                    echo ""
                    echo "Verificando usuario: $USERNAME"
                    USER=$(echo $USERNAME | tr -d \")

                    LAST_USER_INFO=$(aws iam get-user --user-name $USER --profile $ACCOUNT_ID --output json)
                    echo "$LAST_USER_INFO" > resultado/"${ACCOUNT_ID}_${USER}_lastinfo".json

                    USER_KEYS=$(aws iam list-access-keys --user-name $USER --profile $ACCOUNT_ID --output json)
                    echo ""
                    USER_DATA="$USER,$CREATEDATE,$PASSWORDLASTUSED,"
                    USER_KEY_DATA=""
                    if [[ $USER_KEYS ]]; then
                        echo "$USER_KEYS" > resultado/"${ACCOUNT_ID}_${USER}_key".json
                        shopt -s lastpipe
                        jq -c '.AccessKeyMetadata[]' resultado/"${ACCOUNT_ID}_${USER}_key".json | while read item; do
                            USERKEY=$(echo $item | jq '.AccessKeyId')
                            echo ""
                            # echo "Verificando a chave $USERKEY do usuário: $USER"
                            KEY=$(echo $USERKEY | tr -d \")
                            # echo "Chave para formato arquivo: $KEY"
                            KEY_LAST_ACCESS=$(aws iam get-access-key-last-used --access-key-id $KEY --profile $ACCOUNT_ID --output json )
                            # ACCESSKEYLASTUSED=$(aws iam get-access-key-last-used --access-key-id $KEY --profile $ACCOUNT_ID --output json | jq '.AccessKeyLastUsed.LastUsedDate' | tr -d \")
                            ACCESSKEYLASTUSED=$(echo $KEY_LAST_ACCESS | jq '.AccessKeyLastUsed.LastUsedDate' | tr -d \")
                            # echo "Ultima Utilizacao: $ACCESSKEYLASTUSED"
                            echo "" >> resultado/"${ACCOUNT_ID}_${USER}_key".json
                            echo "$KEY_LAST_ACCESS" >> resultado/"${ACCOUNT_ID}_${USER}_key".json

                            if [[ "${ACCESSKEYLASTUSED}" == "null" ]]; then
                                ACCESSKEYLASTUSED=""
                            fi

                            USER_KEY_DATA+="$KEY,$ACCESSKEYLASTUSED,"
                        done

                    fi
                    LINHA="${ACCOUNT_DATA}${USER_DATA}${USER_KEY_DATA}"
                    echo "$LINHA" >> resultado.csv
                done
            fi
        fi
        ACCOUNTS_ARRAY+=($SourceAccountId)
    fi

done
