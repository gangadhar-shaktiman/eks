 variable "subnet_id_1" {
  type = string
  default = "subnet-0c44f87e69bedf89e"
 }
 
 variable "subnet_id_2" {
  type = string
  default = "subnet-09a8e0d6667281cd8"
 }

  variable "sg_ids" {
  type = string
 }

 variable "subnet_ids" {
  type    = list(string)
  default = [var.subnet_id_1, var.subnet_id_2]  
}