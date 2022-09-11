variable "sec_gid" {
  description = "The id for your default security group"
  type        = string
}

variable "ec2_count" {
  description = "The number of EC2 instances to be created"
  type        = number
}

variable "sec_ports" {
  description = "The number of EC2 instances to be created"
  type        = list(string)
}