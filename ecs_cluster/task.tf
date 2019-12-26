data "aws_ecs_task_definition" "test" {
    task_definition = "${aws_ecs_task_definition.test.family}"
    depends_on = ["aws_ecs_task_definition.test"]
}

resource "aws_ecs_task_definition" "test" {
    family = "test-family"
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