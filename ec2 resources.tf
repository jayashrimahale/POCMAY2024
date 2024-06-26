# Create an EC2 Auto Scaling Group - web
resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                 = "three-tier-web-asg"
  launch_configuration = aws_launch_configuration.three-tier-web-lconfig.id
  vpc_zone_identifier  = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
}

# Create an EC2 Auto Scaling Group - app
resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                 = "three-tier-app-asg"
  launch_configuration = aws_launch_configuration.three-tier-app-lconfig.id
  vpc_zone_identifier  = [aws_subnet.three-tier-pvt-sub-1.id, aws_subnet.three-tier-pvt-sub-2.id]
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
}

# Auto Scaling Policy for scaling up/down based on Request Count Per Target - Web ASG
resource "aws_autoscaling_policy" "web_target_tracking_policy" {
  name                   = "web-target-tracking-policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb_target_group.three-tier-web-lb-tg.arn}/targetgroup/${aws_lb_target_group.three-tier-web-lb-tg.arn_suffix}"
    }
    target_value = 100.0
  }
}



# Auto Scaling Policy for scaling up/down based on Request Count Per Target - App ASG
resource "aws_autoscaling_policy" "app_target_tracking_policy" {
  name                   = "app-target-tracking-policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  autoscaling_group_name = aws_autoscaling_group.three-tier-app-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb_target_group.three-tier-app-lb-tg.arn}/targetgroup/${aws_lb_target_group.three-tier-app-lb-tg.arn_suffix}"
    }
    target_value = 100.0
  }
}

###################################################################################################################################

# Create a launch configuration for the EC2 instances
resource "aws_launch_configuration" "three-tier-web-lconfig" {
  name_prefix                 = "three-tier-web-lconfig"
  image_id                    = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t2.micro"
  key_name                    = "terraformmay2024"
  security_groups             = [aws_security_group.three-tier-ec2-asg-sg.id]
  user_data                   = <<-EOF
                                #!/bin/bash
                                # Update the system
                                sudo apt-get -y update
                                # Install Apache web server
                                sudo apt install apache2
                                sudo ufw app list
                                sudo ufw allow 'Apache'
                                sudo ufw status
                                # Start Apache web server
                                sudo systemctl start apache2
                                # Create index.html file with your custom HTML
                                cat <<EOT > /var/www/html/index.html
                                <!DOCTYPE html>
                                <html lang="en">
                                    <head>
                                        <meta charset="utf-8" />
                                        <meta name="viewport" content="width=device-width, initial-scale=1" />
                                        <title>A Basic HTML5 Template</title>
                                        <link rel="preconnect" href="https://fonts.googleapis.com" />
                                        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
                                        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700;800&display=swap" rel="stylesheet" />
                                        <link rel="stylesheet" href="css/styles.css?v=1.0" />
                                    </head>
                                    <body>
                                        <div class="wrapper">
                                            <div class="container">
                                                <h1>Welcome! An Apache web server has been started successfully.</h1>
                                                <h2>Jayashri Mahale</h2>
                                            </div>
                                        </div>
                                    </body>
                                </html>
                                <style>
                                    body {
                                        background-color: #34333d;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        font-family: Inter;
                                        padding-top: 128px;
                                    }
                                    .container {
                                        box-sizing: border-box;
                                        width: 741px;
                                        height: 449px;
                                        display: flex;
                                        flex-direction: column;
                                        justify-content: center;
                                        align-items: flex-start;
                                        padding: 48px 48px 48px 48px;
                                        box-shadow: 0px 1px 32px 11px rgba(38, 37, 44, 0.49);
                                        background-color: #5d5b6b;
                                        overflow: hidden;
                                        align-content: flex-start;
                                        flex-wrap: nowrap;
                                        gap: 24;
                                        border-radius: 24px;
                                    }
                                    .container h1 {
                                        flex-shrink: 0;
                                        width: 100%;
                                        height: auto;
                                        position: relative;
                                        color: #ffffff;
                                        line-height: 1.2;
                                        font-size: 40px;
                                    }
                                    .container p {
                                        position: relative;
                                        color: #ffffff;
                                        line-height: 1.2;
                                        font-size: 18px;
                                    }
                                </style>
                                EOT
                                EOF
                                
  associate_public_ip_address = true
  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}

# Create a launch configuration for the EC2 instances
resource "aws_launch_configuration" "three-tier-app-lconfig" {
  name_prefix                 = "three-tier-app-lconfig"
  image_id                    = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t2.micro"
  key_name                    = "terraformmay2024"
  security_groups             = [aws_security_group.three-tier-ec2-asg-sg-app.id]
  user_data                   = <<-EOF
                                #!/bin/bash

                                sudo apt install mysql-server -y

                                EOF
                                
  associate_public_ip_address = false
  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}
