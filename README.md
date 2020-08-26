[![Follow on Twitter](https://img.shields.io/twitter/follow/opendevsecops.svg?logo=twitter)](https://twitter.com/opendevsecops)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d3cdea1d93de4f9791f92aec8306e6f8)](https://www.codacy.com/app/OpenDevSecOps/terraform-null-archive-builder?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=opendevsecops/terraform-null-archive-builder&amp;utm_campaign=Badge_Grade)

# Local Archive Builder Terraform Module

A helper module to perform builds using local shell and docker.

This module is used extensively throughout other OpenDevSecOps projects as well as [secapps.com](secapps.com).

## Getting Started

The module is automatically published to the Terraform Module Registry. More information about the available inputs, outputs, dependencies, and instructions on how to use the module can be found at the official page [here](https://registry.terraform.io/modules/opendevsecops/archive-builder).

The following example can be used as starting point:

```terraform
module "acme_archive_builder" {
  source  = "opendevsecops/archive-builder/null"
  version = "1.0.0"

  source_dir = "../src/"
  output_dir = "../build/"

  name   = "acme"
  prefix = "emca"

  command   = "pip -r requirements.txt"
  container = "python"
}
```

Later you can use the output to deploy a lambda layer for example:

```terraform
resource "aws_lambda_layer_version" "main" {
  filename         = module.acme_archive_builder.output_file
  source_code_hash = module.acme_archive_builder.output_file_hash

  layer_name          = local.name
  compatible_runtimes = local.runtimes

  depends_on = [
    module.archive-builder
  ]
}
```

Refer to the module registry [page](https://registry.terraform.io/modules/opendevsecops/archive-builder) for additional information on optional inputs and configuration.
