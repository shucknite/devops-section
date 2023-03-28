aws_region        = "ap-southeast-2"

availability_zones = ["ap-southeast-2a", "ap-southeast-2b","ap-southeast-2c"]
public_subnets     = ["10.10.100.0/24", "10.10.101.0/24","10.10.102.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24","10.10.2.0/24"]

# these are used for tags
app_name        = "lightfeather-node-js-app"
app_environment = "lighfeather-production"