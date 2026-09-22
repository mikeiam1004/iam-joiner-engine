module "jml_engine" {
  source = "./modules/jml_engine"

  domain_name    = var.domain_name
  json_data_path = "${path.module}/users.json"
}
