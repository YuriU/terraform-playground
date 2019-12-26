data "aws_vpc" "default" {
  	  default = true
}

data "aws_subnet_ids" "default_subnets_ids" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_subnet" "default_subnets" {
  count = "${length(data.aws_subnet_ids.default_subnets_ids.ids)}"
  id    = "${data.aws_subnet_ids.default_subnets_ids.ids[count.index]}"
}