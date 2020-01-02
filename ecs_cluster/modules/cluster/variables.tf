variable "ClusterName" {
}

variable "MinInstancesCount" {
}

variable "MaxInstancesCount" {
}

variable "InstanceAMI" {
}

variable "InstanceType" {
}

variable "SubnetIds" {
   type = "list"
}

variable "BalancerSecurityGroupId" {
}