data "aws_subnet" "existing_subnets" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

resource "aws_subnet" "example_subnets" {
  count  = length(data.aws_subnet.existing_subnets)
  vpc_id = "vpc-011f1b733d94aa911"
  cidr_block = data.aws_subnet.existing_subnets[count.index].cidr_block

  tags = {
    "Name"                       = "public-ap-south-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax_cluster" = "shared"
  }
}

