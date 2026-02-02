variable "tags" {
  type = map(string)
  default = {
    "Name" = "DevOpsVPC"
  }
}

variable "public_subnet" {
  type = map(string)
  default = {
    Name       = "DevOpsPublicSubnet"
    cidr_block = "10.0.1.0/24"
  }
}

variable "private_subnet" {
  type = map(string)
  default = {
    Name       = "DevOpsPrivateSubnet"
    cidr_block = "10.0.2.0/24"
  }
}

variable "internet_gateway" {
  type    = string
  default = "DevOpsInternetGateway"
}

variable "route_table" {
  type    = string
  default = "DevOpsRouteTable"
}

variable "nat_gateway" {
  type    = string
  default = "DevOpsNATGateway"
}

variable "sg" {
  type    = string
  default = "DevOpsSecurityGroup"
}

