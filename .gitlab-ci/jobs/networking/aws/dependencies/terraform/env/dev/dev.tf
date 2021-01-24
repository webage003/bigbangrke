module "dev" {
  source   = "../../main"
  env      = "tunde-dev"
  vpc_cidr = "10.23.0.0/16"
}
