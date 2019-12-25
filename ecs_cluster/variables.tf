variable "ClusterName" {
  default = "TestCluster"
}

variable "InstancesCount" {
  default = 1
}

# AMI are region specific. Need to add mapping later
variable "InstanceAMI" {
    default = "ami-0ab1db011871746ef"
}

variable "InstanceType" {
    default = "t2.micro"
}