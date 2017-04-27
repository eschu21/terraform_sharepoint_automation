### Establish Provider and Access ###


### VPC Creation ###
resource "aws_vpc" "sharepoint" {
  cidr_block = "10.100.101.0/24"
  enable_dns_hostnames = "true"
  tags {
    Name = "${var.stack_name}"
  }
}


### Create Subnet for all of our resources ###
resource "aws_subnet" "default" {
  vpc_id     = "${aws_vpc.sharepoint.id}"
  cidr_block = "10.100.101.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.stack_name}"
  }
}


### IGW for external calls ###
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.sharepoint.id}"
  tags {
    Name = "${var.stack_name}"
  }
}


### Route Table ###
resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.sharepoint.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}


### Main Route Table ###
resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.sharepoint.id}"
  route_table_id = "${aws_route_table.main.id}"
}


### Provide a VPC DHCP Option Association ###
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.sharepoint.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}


### Set DNS resolvers so we can join a Domain Controller ###
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = [
    "8.8.8.8",
    "8.8.4.4",
    "${aws_instance.sharepoint_ad_server.private_ip}"
  ]
  tags {
    Name = "${var.stack_name}"
  }
}


### Security Group Creation ###
resource "aws_security_group" "sharepoint_stack" {
  name        = "Sharepoint_Stack"
  description = "Security Group for Sharepoint_Stack"
  vpc_id      = "${aws_vpc.sharepoint.id}"
  tags        = {
    Name = "${var.stack_name}"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = "true"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### INLINE - Bootsrap Windows Server 2012 R2 ###
data "template_file" "init" {
    template = <<EOF
    <script>
      winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm/config @{MaxEnvelopeSizekb="8000kb"}
    </script>
    <powershell>
     netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
     $admin = [ADSI]("WinNT://./administrator, user")
     $admin.SetPassword("${var.admin_password}")
    </powershell>
EOF
    vars {
      admin_password = "${var.admin_password}"
    }
}


### INLINE - W2012R2 - Sharepoint AD Server ###
resource "aws_instance" "sharepoint_ad_server" {
  ami              = "${lookup(var.aws_w2012r2_std_amis, var.aws_region)}"
  instance_type    = "${var.aws_app_instance_type}"
  key_name         = "${lookup(var.key_name, var.aws_region)}"
  user_data        = "${data.template_file.init.rendered}"
  subnet_id        = "${aws_subnet.default.id}"
  private_ip       = "10.100.101.50"
  vpc_security_group_ids = [
    "${aws_security_group.sharepoint_stack.id}"
  ]
  tags  = {
    Name = "${var.ad_node_name}"
  }

  ### Allow AWS infrastructure metadata to propagate ###
  provisioner "local-exec" {
    command = "sleep 60"
  }

  ### Copy Scripts to EC2 instance ###
  provisioner "file" {
    source      = "${path.module}/activedirectory/"
    destination = "C:\\scripts"
    connection   = {
     type        = "winrm"
     user        = "Administrator"
     password    = "${var.admin_password}"
     agent       = "false"
    }
  }

  ### Set Execution Policy to Remote-Signed, Configure Active Directory ###
  provisioner "remote-exec" {
    connection = {
     type        = "winrm"
     user        = "Administrator"
     password    = "${var.admin_password}"
     agent       = "false"
    }
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -version 4 -ExecutionPolicy Bypass -File C:\\scripts\\01-ad_init.ps1"
    ]
  }
}


### INLINE - W2012R2 - Sharepoint DB Server ###
resource "aws_instance" "sharepoint_db_server" {
  ami              = "${lookup(var.aws_w2012r2_mssql2014_amis, var.aws_region)}"
  instance_type    = "${var.aws_db_instance_type}"
  key_name         = "${lookup(var.key_name, var.aws_region)}"
  user_data        = "${data.template_file.init.rendered}"
  subnet_id        = "${aws_subnet.default.id}"
  depends_on       = ["aws_instance.sharepoint_ad_server"]
  private_ip       = "10.100.101.51"
  vpc_security_group_ids = [
    "${aws_security_group.sharepoint_stack.id}"
  ]
  tags  = {
    Name = "${var.db_node_name}"
  }

  ### Allow AWS infrastructure metadata to propagate ###
  provisioner "local-exec" {
    command = "sleep 300"
  }

  ### Copy Scripts to EC2 instance ###
  provisioner "file" {
    source      = "${path.module}/mssql/"
    destination = "C:\\scripts"
    connection   = {
     type        = "winrm"
     user        = "Administrator"
     password    = "${var.admin_password}"
     agent       = "false"
    }
  }

  ### Set Execution Policy to Remote-Signed, Configure SQL Server ###
  provisioner "remote-exec" {
    connection = {
     type        = "winrm"
     user        = "Administrator"
     password    = "${var.admin_password}"
     agent       = "false"
    }
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -version 4 -ExecutionPolicy Bypass -File C:\\scripts\\01-mssql_ad_join.ps1"
    ]
  }
}


### INLINE - W2012R2 - Sharepoint App Server ###
resource "aws_instance" "sharepoint_app_server" {
  ami              = "${lookup(var.aws_w2012r2_std_amis, var.aws_region)}"
  instance_type    = "${var.aws_app_instance_type}"
  key_name         = "${lookup(var.key_name, var.aws_region)}"
  user_data        = "${data.template_file.init.rendered}"
  subnet_id        = "${aws_subnet.default.id}"
  private_ip       = "10.100.101.52"
  depends_on       = ["aws_instance.sharepoint_ad_server","aws_instance.sharepoint_db_server"]
  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_size           = 100
    volume_type           = "standard"
    delete_on_termination = true
  }
  vpc_security_group_ids = [
    "${aws_security_group.sharepoint_stack.id}"
  ]
  tags  = {
    Name = "${var.app_node_name}"
  }


  ### Allow AWS infrastructure metadata to propagate ###
  provisioner "local-exec" {
    command = "sleep 90"
  }


  ### Copy Scripts to EC2 instance ###
  provisioner "file" {
    source      = "${path.module}/sharepoint/"
    destination = "C:\\scripts"
    connection   = {
     type        = "winrm"
     user        = "Administrator"
     password    = "${var.admin_password}"
     agent       = "false"
    }
  }


  ### Set Execution Policy to Remote-Signed, Install Sharepoint ###
  provisioner "remote-exec" {
    connection = {
     type        = "winrm"
     user        = "Administrator"
     password    = "${var.admin_password}"
     agent       = "false"
    }
    inline = [
      "powershell.exe Set-ExecutionPolicy Unrestricted -force",
      "echo ${aws_instance.sharepoint_ad_server.private_ip} >> C:\\scripts\\ad_ip.txt",
      "echo ${aws_instance.sharepoint_db_server.private_ip} >> C:\\scripts\\db_info.txt",
      "powershell.exe -version 4 -ExecutionPolicy Bypass -File C:\\scripts\\00-sp_ad_join.ps1"
    ]
  }
}
