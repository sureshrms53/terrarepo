provider "aws" {
	access_key = "AKIAZTIMJ7JHPVODYVZA"
	secret_key = "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"
	region = "eu-west-1"
}


resource "aws_instance" "rmsterraform1" {
	ami = "ami-0bbc25e23a7640b9b"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.rmskey.id}"
	vpc_security_group_ids = ["${aws_security_group.rmstfsecgroup.id}"]
	tags ={
				Name = "rmsinstance"
			}
	provisioner "local-exec" {
		when = "create"
		command = "echo ${aws_instance.rmsterraform1.public_ip}>sample.txt"
		}
	
	provisioner "chef" {
		connection {
			host = "${self.public_ip}"
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("C:\\terraform_rms\\key.pem")}"
			}
		client_options = ["chef_license 'accept'"]
		run_list = ["testenv_aws_tf_chef::default"]
		recreate_client = true
		node_name = "rmnode"
		server_url = "https://api.chef.io/organizations/terdem"
		user_name = "sureshrm"
		user_key = "${file("C:\\chef-repo\\.chef\\sureshrm.pem")}"
		ssl_verify_mode = ":verify_none"
		}
}

output "rmspublicip" {
	value = "${aws_instance.rmsterraform1.public_ip}"
}

resource "aws_key_pair" "rmskey" {
	key_name = "rmskeypair"
	public_key = "${file ("C:\\terraform_rms\\key.pub")}"
}

resource "aws_eip" "rmseip" {
	tags = {
		Name = "rmseip1"
		}
	instance = "${aws_instance.rmsterraform1.id}"
}
resource "aws_security_group" "rmstfsecgroup" {
	name = "rmssecgrop1"
	description = "To allow traffic"
	
	ingress {
		 from_port = "0"
		 to_port = "0"
		 protocol = "-1"
		 cidr_blocks = ["0.0.0.0/0"]
		 }
		 
	egress {
	from_port = "0"
		 to_port = "0"
		 protocol = "-1"
		 cidr_blocks = ["0.0.0.0/0"]
	}
	
}

resource "aws_s3_bucket" "rmsurbucket" {
	bucket = "rmsurbucket1"
	acl = "private"
	force_destroy = "true"
}

terraform {
	backend "s3" {
		bucket = "rmsurbucket1"
		key = "terraform.tfstate"
		region = "eu-west-1"
	}
}



