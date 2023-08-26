data "aws_subnet" "existing_subnets" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

resource "aws_subnet" "example_subnets" {
  count = length(var.subnet_ids)
  vpc_id = "vpc-011f1b733d94aa911"
  subnet_id    = data.aws_subnet.existing_subnets[count.index].id
  tags = {
    "Name"                       = "public-ap-south-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax_cluster" = "shared"
  }
}
