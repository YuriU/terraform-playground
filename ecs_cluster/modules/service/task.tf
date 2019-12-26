data "aws_ecs_task_definition" "existing_task_definition" {
    task_definition = "${aws_ecs_task_definition.task_definition.family}"
    depends_on = ["aws_ecs_task_definition.task_definition"]
}

resource "aws_ecs_task_definition" "task_definition" {
    family = "${var.ServiceName}"
    container_definitions = <<DEFINITION
    [
        {
            "name": "apache",
            "image": "bitnami/apache:latest",
            "memory": 128,
            "cpu": 128,
            "essential": true,
            "portMappings": [
                {
                "hostPort": 0,
                "containerPort": 8080,
                "protocol": "tcp"
                }
            ]
        }
    ]
    DEFINITION
}