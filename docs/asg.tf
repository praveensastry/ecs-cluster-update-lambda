# Example Autoscaling group resource which can used along with lambda
resource "aws_cloudformation_stack" "autoscaling_group" {
  name = "${var.cfn_stack_name}"

  template_body = <<EOF
Description: "${var.cfn_stack_description}"
Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier: ["${join("\",\"", var.subnets)}"]
      AvailabilityZones: ["${join("\",\"", var.availability_zones)}"]
      LaunchConfigurationName: "${aws_launch_configuration.ecs.name}"
      MinSize: "${var.asg_min_size}"
      MaxSize: "${var.asg_max_size}"
      DesiredCapacity: "${var.asg_desired_capacity}"
      HealthCheckType: EC2

    CreationPolicy:
      AutoScalingCreationPolicy:
        MinSuccessfulInstancesPercent: 80
      ResourceSignal:
        Count: "${var.cfn_signal_count}"
        Timeout: PT10M
    UpdatePolicy:
    # Ignore differences in group size properties caused by scheduled actions
      AutoScalingScheduledAction:
        IgnoreUnmodifiedGroupSizeProperties: true
      AutoScalingRollingUpdate:
        MaxBatchSize: "${var.asg_max_size}"
        MinInstancesInService: "${var.asg_min_size}"
        MinSuccessfulInstancesPercent: 80
        PauseTime: PT10M
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
        WaitOnResourceSignals: true
    DeletionPolicy: Retain
  EOF
}
