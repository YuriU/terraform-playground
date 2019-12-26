resource "aws_security_group" "web_server" {
  
  #inbound
  ingress {
	  from_port = 80
	  to_port = 80
	  protocol = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
	  from_port = 0
	  to_port = 0
	  protocol = "-1"
	  cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "main" {
    name = "my-alb-ecs"
    subnets = ["${data.aws_subnet.default_subnets.*.id}"]
    security_groups = ["${aws_security_group.web_server.id}"]
}
