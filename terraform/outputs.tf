output "ec2_public_ips" {
  value = ["${aws_instance.monitor.*.public_ip}"]
}