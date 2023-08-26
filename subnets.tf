data "aws_subnet" "existing_subnets" {
  count = length(concat(var.subnet_id_1, var.subnet_id_2))
  id    = element(concat(var.subnet_id_1, var.subnet_id_2), count.index)
}

resource "aws_subnet" "example_subnets" {
  count = length(concat(var.subnet_id_1, var.subnet_id_2))
  id    = data.aws_subnet.existing_subnets[count.index].id
  tags = {
    "Name"                       = "public-ap-south-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax_cluster" = "shared"
  }
}

