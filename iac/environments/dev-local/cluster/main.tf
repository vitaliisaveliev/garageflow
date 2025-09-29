module "cluster_k3d" {
  source       = "../../../modules/cluster-k3d"

  cluster_name = "garageflow-dev"
  servers      = 1
  agents       = 2
  http_port    = 80     # было 8081
  https_port   = 443    # было 8444
}
