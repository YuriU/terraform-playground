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

resource "aws_alb_listener" "front_end" {
    load_balancer_arn = "${aws_alb.main.id}"
    port = "80"
    protocol = "HTTP"

    default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No service found"
      status_code  = "200"
    }
  }
}