# Reference: https://registry.terraform.io/providers/poseidon/ct/latest/docs/data-sources/ct_config
# Transpile Butane configs to Ignition with variable substitution
data "ct_config" "ignition" {
  content = templatefile("../ignition/base.yaml", {
    password_hash  = var.password_hash
    ssh_public_key = var.ssh_public_key
  })
  strict       = true
  pretty_print = true

  snippets = [
    file("../ignition/nomad.yaml"),
    file("../ignition/consul.yaml"),
  ]
}

# Make the rendered Ignition config available as a local file
resource "local_file" "ignition_config" {
  content  = data.ct_config.ignition.rendered
  filename = "${path.module}/ignition.json"
}
