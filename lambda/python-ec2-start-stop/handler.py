import boto3

ec2 = boto3.client('ec2')


def start_ec2(event, context):
    ec2_instances = get_all_ec2_ids()
    response = ec2.start_instances(
        InstanceIds=ec2_instances,
        DryRun=False
    )
    return response


def stop_ec2(event, context):
    ec2_instances = get_all_ec2_ids()
    response = ec2.stop_instances(
        InstanceIds=ec2_instances,
        DryRun=False
    )
    return response


# get the list of all the ec2 instances
def get_all_ec2_ids():
    response = ec2.describe_instances(DryRun=False)
    instances = []
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            # This sample print will output entire Dictionary object
            # This will print will output the value of the Dictionary key 'InstanceId'
            instances.append(instance["InstanceId"])
    return instances
