### Security

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "tf-${var.environ}-alb"
  description = "controls access to the ALB"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "tf-${var.environ}-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol        = "tcp"
    from_port       = 1
    to_port         = 65535
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### ALB

resource "aws_alb" "main" {
  name            = "tf-ecs-${var.environ}"
  subnets         = aws_subnet.public.*.id
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "app" {
  name        = "tf-ecs-${var.environ}"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"
}
/*
# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:033818603844:certificate/3cf4d68d-952a-4935-a072-c503dfed927b"
  

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}
*/

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "tf-staging-cluster"
}

resource "aws_ecs_service" "main" {
  name            = "tf-${var.environ}-textatow"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "arn:aws:ecs:us-east-1:033818603844:task-definition/staging-textatow-tasks"
  desired_count   = "1"
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = 20

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = aws_subnet.public.*.id
	  assign_public_ip = "true"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "${var.environ}-web"
    container_port   = "5000"
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}