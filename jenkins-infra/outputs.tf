output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
output "instance_id" {
  value = aws_instance.jenkins.id
}
output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
output "sonar_url" {
  value = "http://${aws_instance.jenkins.public_ip}:9000"
}
output "your_ip_allowed" {
  value = "${chomp(data.http.myip.response_body)}/32"
}
