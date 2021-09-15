#!/bin/bash -e

################################################################################
###
### *** SCRIPT VALIDO APENAS PARA CONTAS DE PROJETO ***
###
### *** PARA CONTAS DE INFRAESTRUTURA ESSE SCRIPT ** NAO ** DEVE SER USADO ***
###
################################################################################

################################################################################
### CONFIGURA OS GRUPOS DE ACESSOS DO SECGOV EM UMA DETERMINADA CONTA DE PROJETO
################################################################################

TARGET_PROJECT_ACCOUNT_ID=$1
AWS_PROFILE=$2

if [[ -z ${TARGET_PROJECT_ACCOUNT_ID} ]] || [[ -z ${AWS_PROFILE} ]] ; then
  echo "use: ./assign-groups-secgov-to-account.sh <TARGET-ACCOUNT-ID> <AWS_PROFILE>"
  exit -1
fi

echo "Assigning to SecGov-BlueTeams-Admins : SecGovBlueTeamAdmins"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-3372dc4c66aa7697 \
          --principal-type GROUP \
          --principal-id 90676779f6-ffdf6f47-5ddc-49eb-9d65-00fb43dbf209 \
          --profile ${AWS_PROFILE}
          
echo "Assigning to SecGov-Billing-ReadOnly : SecGovBillingReadOnly"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-78d0566af4854c08 \
          --principal-type GROUP \
          --principal-id 90676779f6-10785c40-8368-454e-ab0d-99bac1568997 \
          --profile ${AWS_PROFILE}
          
echo "Assigning to AWSControlTowerAdmins : AWSOrganizationsFullAccess"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-f1031522a248d9ce \
          --principal-type GROUP \
          --principal-id 90676779f6-3e316176-c311-4fee-8d97-80c399e27018 \
          --profile ${AWS_PROFILE}

echo "Assigning to AWSSecurityAuditPowerUsers : AWSPowerUserAccess"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-7e645d945133b643 \
          --principal-type GROUP \
          --principal-id 90676779f6-22c588fe-b602-4be2-a001-f6b7f5547c1b \
          --profile ${AWS_PROFILE}

echo "Assigning to SecGov-Support-Admins : SecGovSuportAdmins"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-fe73e23e41249ff2 \
          --principal-type GROUP \
          --principal-id 90676779f6-3cecb5d8-3d34-49ec-8bdf-b34e546e6d98 \
          --profile ${AWS_PROFILE}

echo "Assigning to AWSSecurityAuditors - AWSReadOnlyAccess"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-7b46a8eb8858b707 \
          --principal-type GROUP \
          --principal-id 90676779f6-c0b61830-cf14-4b86-b1c4-85f1d4bae060 \
          --profile ${AWS_PROFILE}

echo "Assigning to ${AWS_PROFILE}-admins : ProjectAdministrator"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-3372dc4c66aa7697 \
          --principal-type GROUP \
          --principal-id 90676779f6-ffdf6f47-5ddc-49eb-9d65-00fb43dbf209 \
          --profile ${AWS_PROFILE}    

echo "Assigning to ${AWS_PROFILE}-powerusers : ProjectPowerUser"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-3372dc4c66aa7697 \
          --principal-type GROUP \
          --principal-id 90676779f6-ffdf6f47-5ddc-49eb-9d65-00fb43dbf209 \
          --profile ${AWS_PROFILE} 

echo "Assigning to ${AWS_PROFILE}-sysadmin : ProjectSysAdmin"
aws sso-admin create-account-assignment --instance-arn arn:aws:sso:::instance/ssoins-7223f20b30706c6b \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn arn:aws:sso:::permissionSet/ssoins-7223f20b30706c6b/ps-3372dc4c66aa7697 \
          --principal-type GROUP \
          --principal-id 90676779f6-ffdf6f47-5ddc-49eb-9d65-00fb43dbf209 \
          --profile ${AWS_PROFILE} 
