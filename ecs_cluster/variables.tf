variable "ClusterName" {
  default = "TestCluster"
}

variable "MinInstancesCount" {
  default = 1
}

variable "MaxInstancesCount" {
  default = 5
}

# AMI are region specific. Need to add mapping later
variable "InstanceAMI" {
    default = "ami-01933d3dbcb8f63e0"
}

variable "InstanceType" {
    default = "t2.micro"
}