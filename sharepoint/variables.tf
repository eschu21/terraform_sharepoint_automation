## Provider Variables ##


variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = {
    "us-east-1" = "eschumann_key"
    "us-west-2" = "eschumann_key"
  }
}


# Windows Server 2012 R2 Base AMI
variable "aws_w2012r2_std_amis" {
  default = {
    us-east-1 = "ami-3f0c4628"
    us-west-2 = "ami-1562d075"
  }
}

## Windows Server 2012 R2 WITH MSSQL 2014 ##
variable "aws_w2012r2_mssql2014_amis" {
  default = {
    us-east-1 = "ami-7dcd646b"
    us-west-2 = "ami-65820b05"
  }
}

variable "aws_app_instance_type" {
  default = "t2.large"
}

variable "aws_db_instance_type" {
  default = "m4.large"
}

variable "aws_subnet_id" {
  default = {
    "us-east-1" = "subnet-xxxxxxxx"
    "us-west-2" = "subnet-xxxxxxxx"
  }
}

variable "aws_security_group" {
  default = {
    "us-east-1" = "sg-xxxxxxxx"
    "us-west-2" = "sg-xxxxxxxx"
  }
}


### Stack Name to be associated with all resources ###
variable "stack_name" {
	default = "Sharepoint_Stack"
}


## Server Names ##
variable "app_node_name" {
  default = "Sharepoint_App_Server"
}

variable "db_node_name" {
	default = "Sharepoint-DB-MSSQL"
}

variable "ad_node_name" {
	default = "Sharepoint-AD"
}

variable "sharepoint_stack_vpc" {
  default = "vpc-41e97926"
}




##### Script Related Resources #####


## Set Initial Windows Administrator Password ##
variable "admin_password" {
  description = "Windows Administrator password to login as."
	default = "Summer01!"
}

variable "sp_admin" {
	default = "Summer01!"
}
