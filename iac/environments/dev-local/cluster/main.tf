module "cluster_k3d" {
  source       = "../../../modules/cluster-k3d"

  cluster_name = "garageflow-dev"
  servers      = 1
  agents       = 2
  http_port    = 8081
  https_port   = 8444
}
