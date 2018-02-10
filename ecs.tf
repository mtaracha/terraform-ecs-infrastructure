provider "aws" {
  region = "eu-west-1"
}

data "aws_security_group" "default" {
  vpc_id = "${module.ecs-vpc.vpc_id}"
  name   = "default"
}
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}
/*
  ASG definition
*/
module "ecs-asg" {
  source = "git::ssh://git@github.com/mtaracha/terraform-aws-autoscaling.git?ref=terraform-aws-autoscaling@latest"

  name                        = "ecs"
  lc_name                     = "ecs"
  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "m3.medium"
  spot_price                  = "0.01"
  security_groups             = ["${data.aws_security_group.default.id}"]

  # Auto scaling group
  asg_name                  = "ecs-asg"
  vpc_zone_identifier       = ["${module.ecs-vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 0
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "R&D"
      propagate_at_launch = true
    },
  ]
}
