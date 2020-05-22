locals {
  name   = var.name
  prefix = var.prefix

  source_dir = var.source_dir
  output_dir = var.output_dir

  output_source_file = join("/", [local.output_dir, "${local.prefix}${local.name}.source.zip"])

  output_docker_command_dir  = join("/", [local.output_dir, "${local.prefix}${local.name}.docker_command"])
  output_docker_command_file = join("/", [local.output_dir, "${local.prefix}${local.name}.docker_command.zip"])

  docker_command       = var.docker_command
  docker_command_count = local.docker_command == null ? 0 : 1

  tags = var.tags
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.output_source_file
}

resource "null_resource" "docker_command" {
  count = local.docker_command_count

  triggers = {
    output_docker_command_file_exists = fileexists(local.output_docker_command_file)

    output_docker_command_file = local.output_docker_command_file
    output_docker_command_dir  = local.output_docker_command_dir

    container = local.docker_command.container
    command   = local.docker_command.command

    source_archive_file_hash = data.archive_file.source.output_base64sha256
  }

  provisioner "local-exec" {
    environment = {
      SOURCE_DIR              = local.source_dir
      OUTPUT_DOCKER_BUILD_DIR = local.output_docker_command_dir
    }

    command = <<EOF
rm -rf "$$OUTPUT_DOCKER_BUILD_DIR"
cp -rT "$SOURCE_DIR" "$OUTPUT_DOCKER_BUILD_DIR"
EOF
  }

  provisioner "local-exec" {
    working_dir = local.output_docker_command_dir

    environment = {
      DOCKER_CONTAINER = local.docker_command.container
      DOCKER_COMMAND   = local.docker_command.command
    }

    command = <<EOF
docker run -v "$PWD":/var/task "$DOCKER_CONTAINER" /bin/sh -c "$DOCKER_COMMAND"
EOF
  }

  provisioner "local-exec" {
    environment = {
      OUTPUT_DOCKER_BUILD_DIR  = local.output_docker_command_dir
      OUTPUT_DOCKER_BUILD_FILE = local.output_docker_command_file
    }

    command = <<EOF
zip -r "$OUTPUT_DOCKER_BUILD_FILE" "$OUTPUT_DOCKER_BUILD_DIR"
EOF
  }
}

data "archive_file" "docker_command" {
  count = local.docker_command_count

  type        = "zip"
  source_dir  = local.output_docker_command_dir
  output_path = local.output_docker_command_file

  depends_on = [
    null_resource.docker_command
  ]
}
