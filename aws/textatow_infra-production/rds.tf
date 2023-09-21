resource "aws_db_subnet_group" "default" {
  name       = "production_main"
  subnet_ids = aws_subnet.production_private.*.id
}


# Traffic to postgres from the fargate tasks
resource "aws_security_group" "postgres" {
  name        = "tf-postgres"
  description = "allow inbound access from the fargate tasks"
  vpc_id      = "${aws_vpc.production_main.id}"

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = ["${aws_security_group.production_ecs_tasks.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ssm_parameter" "database_password" {
  name = "/textatow/${var.environ}/DATABASE_PASSWORD"
}

resource "aws_db_instance" "production_postgres" {
   allocated_storage    = "20"
   storage_type         = "gp2"
   engine               = "postgres"
   engine_version       = "15.3"
   instance_class       = "db.t3.micro"
   multi_az             = "false"
   identifier           = "${var.environ}db"
   db_name              = "${var.environ}_db"
   username             = "postgres"
   password             = data.aws_ssm_parameter.database_password.insecure_value
   db_subnet_group_name = "${aws_db_subnet_group.default.name}"
   parameter_group_name = "default.postgres15"
   skip_final_snapshot  = "true"
   storage_encrypted    = true
   vpc_security_group_ids = ["${aws_security_group.postgres.id}"]
   deletion_protection  = true
}