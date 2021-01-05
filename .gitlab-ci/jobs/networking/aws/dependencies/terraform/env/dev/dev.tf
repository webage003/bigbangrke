module "dev" {
  source   = "../../main"
  env      = "ismail-dev"
  vpc_cidr = "10.255.0.0/16"
}
