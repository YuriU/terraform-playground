variable "ClusterName" {
  //default = "TestCluster"
}

variable "InstancesCount" {
  //default = 1
}

# AMI are region specific. Need to add mapping later
variable "InstanceAMI" {
    //default = "ami-01933d3dbcb8f63e0"
}

variable "InstanceType" {
    //default = "t2.micro"
}

variable "SubnetIds" {
   type = "list"
}