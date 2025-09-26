variable "cluster_name" {
  description = "K3d cluster name"
  type = string
  default = "garageflow-dev"
}

variable "servers" {
  description = "Number of server nodes"
  type = number
  default = 1
}

variable "agents" {
  description = "Numbers of agent nodes"
  type = number
  default = 2
}

variable "http_port" {
  description = "Host port for HTTP LB"
  type = number
  default = 80
}

variable "https_port" {
  description = "Host port for HTTPS LB"
  type = number
  default = 443
}
