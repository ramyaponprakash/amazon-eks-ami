
data "template_file" "squid_userdata" {
  template = file("${path.module}/userdata.sh")
  vars = {
    region = var.region
  }
}

data "template_file" "squid_userdata_green" {
  template = file("${path.module}/userdata-green.sh")
  vars = {
    region = var.region
  }
}

resource "aws_launch_template" "squid_launch_template" {
  name          = "${var.vpc_name}-squid-launch-template"
  description   = "${var.vpc_name}-squid-launch-template"
  image_id      = var.squid.ami_squid
  instance_type = var.squid.instance_type
  iam_instance_profile {
    name = var.squid.iam_role
  }
  vpc_security_group_ids = [aws_security_group.squidproxy.id]
  key_name               = var.squid.squid_key_name
  user_data              = base64encode(data.template_file.squid_userdata.rendered)
  ebs_optimized          = true
  #default_version = 1
  #update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvdcz"
    ebs {
      volume_size           = 25
      delete_on_termination = true
      volume_type           = "gp2"
      encrypted             = "true"
      kms_key_id            = var.squid.kms_key_id
    }
  }
  monitoring {
    enabled = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.vpc_name}-squid-launch-template"
      Remarks = "CTS - RHEL image "
    }
  }
  lifecycle {
    ignore_changes        = all
  }
}

# Autoscaling Group Resource
resource "aws_autoscaling_group" "squid_asg" {
  name_prefix         = "${var.vpc_name}-squid-asg-"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = [var.squid.subnet_ids[0]]
  #target_group_arns   = [aws_lb_target_group.sense_nlb_target_group.arn, aws_lb_target_group.sense_nlb_target_group_8883.arn, aws_lb_target_group.sense_nlb_target_group_5672.arn, aws_lb_target_group.sense_nlb_target_group_5671.arn, aws_lb_target_group.sense_nlb_target_group_15672.arn, aws_lb_target_group.sense_nlb_target_group_15675.arn, ]
  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds
  # Launch Template
  launch_template {
    id      = aws_launch_template.squid_launch_template.id
    version = aws_launch_template.squid_launch_template.latest_version
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.vpc_name}-squid"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "prd" //var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Custodian-Scheduler-StopTime"
      value               = "off=();tz=sgt"
      propagate_at_launch = true
    },
    {
      key                 = "PatchGroup"
      value               = "Prd"
      propagate_at_launch = true
    },
  ]
}

/*resource "aws_launch_template" "squid_launch_template_green" {
  name          = "${var.vpc_name}-squid-launch-template-green"
  description   = "${var.vpc_name}-squid-launch-template-green"
  image_id      = var.squid.ami_squid_green
  instance_type = var.squid.instance_type
  iam_instance_profile {
    name = var.squid.iam_role
  }
  vpc_security_group_ids = [aws_security_group.squidproxy.id]
  key_name               = var.squid.squid_key_name
  user_data              = base64encode(data.template_file.squid_userdata_green.rendered)
  ebs_optimized          = true
  #default_version = 1
  #update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvdcz"
    ebs {
      volume_size           = 25
      delete_on_termination = true
      volume_type           = "gp2"
      encrypted             = "true"
      kms_key_id            = var.squid.kms_key_id
    }
  }
  monitoring {
    enabled = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.vpc_name}-squid-launch-template"
      Remarks = "GT_GCCS_StandardBuild_RHEL_8_on_2024-07-18_06.17.25 "
    }
  }
  lifecycle {
    ignore_changes        = all
  }
}

# Autoscaling Group Resource
resource "aws_autoscaling_group" "squid_asg_green" {
  name_prefix         = "${var.vpc_name}-squid-asg-"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = [var.squid.subnet_ids[0]]
  #target_group_arns   = [aws_lb_target_group.sense_nlb_target_group.arn, aws_lb_target_group.sense_nlb_target_group_8883.arn, aws_lb_target_group.sense_nlb_target_group_5672.arn, aws_lb_target_group.sense_nlb_target_group_5671.arn, aws_lb_target_group.sense_nlb_target_group_15672.arn, aws_lb_target_group.sense_nlb_target_group_15675.arn, ]
  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds
  # Launch Template
  launch_template {
    id      = aws_launch_template.squid_launch_template_green.id
    version = aws_launch_template.squid_launch_template_green.latest_version
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }

  tags = [
    {
      key                 = "Name"
      value               = "test-${var.vpc_name}-squid"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "prd" //var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Custodian-Scheduler-StopTime"
      value               = "off=();tz=sgt"
      propagate_at_launch = true
    },
    {
      key                 = "PatchGroup"
      value               = "Prd"
      propagate_at_launch = true
    },
  ]
}*/

resource "aws_instance" "squid_green" {
  count = 1
  ami                         = var.squid.ami_squid_green
  instance_type               = var.squid.instance_type
  key_name                    = var.squid.squid_key_name
  subnet_id                   = [var.squid.subnet_ids[0]]
  vpc_security_group_ids      = [aws_security_group.squidproxy.id]
  user_data_base64            = base64encode(data.template_file.squid_userdata_green.rendered)
  iam_instance_profile        = var.squid.iam_role
  user_data_replace_on_change = true

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name                          = "test-${var.vpc_name}-squid"
    PatchGroup                    = "Prd"
    Custodian-Scheduler-StopTime  = "off=();tz=sgt"
    Group                         = "squid"
    Environment                   = "prd"
    Remarks                       = "GT_GCCS_StandardBuild_RHEL_8_on_2024-07-18_06.17.25 "
  }
}

resource "aws_autoscaling_attachment" "sdx_intra_prd_nlb_jaeger_att" {
  alb_target_group_arn   = aws_lb_target_group.squid_target_group_3128.arn
  autoscaling_group_name = aws_autoscaling_group.squid_asg.id
}