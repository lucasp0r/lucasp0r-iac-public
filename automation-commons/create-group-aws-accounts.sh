#!/bin/bash -e


################################################################################

################################################################################
### Configura acesso a grupos SSO organização
################################################################################

TARGET_PROJECT_ACCOUNT_ID=$1
AWS_PROFILE=$2
PRINCIPAL_ID=$3
PERMISSION_SET_ARN=$4
INSTANCE_ARN=$5

if [[ -z ${TARGET_PROJECT_ACCOUNT_ID} ]] || [[ -z ${AWS_PROFILE} ]] ; then
  echo "use: ./assign-groups-orgaws-to-account.sh <TARGET-ACCOUNT-ID> <AWS_PROFILE>"
  exit -1
fi

echo "Assigning to SecGov-BlueTeams-Admins : SecGovBlueTeamAdmins"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}
          
echo "Assigning to SecGov-Billing-ReadOnly : SecGovBillingReadOnly"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}
          
echo "Assigning to AWSControlTowerAdmins : AWSOrganizationsFullAccess"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}

echo "Assigning to AWSSecurityAuditPowerUsers : AWSPowerUserAccess"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}

echo "Assigning to SecGov-Support-Admins : SecGovSuportAdmins"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}

echo "Assigning to AWSSecurityAuditors - AWSReadOnlyAccess"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}

echo "Assigning to ${AWS_PROFILE}-admins : ProjectAdministrator"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE}    

echo "Assigning to ${AWS_PROFILE}-powerusers : ProjectPowerUser"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE} 

echo "Assigning to ${AWS_PROFILE}-sysadmin : ProjectSysAdmin"
aws sso-admin create-account-assignment --instance-arn ${INSTANCE_ARN} \
          --target-id ${TARGET_PROJECT_ACCOUNT_ID} \
          --target-type AWS_ACCOUNT \
          --permission-set-arn ${PERMISSION_SET_ARN} \
          --principal-type GROUP \
          --principal-id ${PRINCIPAL_ID} \
          --profile ${AWS_PROFILE} 
