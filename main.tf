locals {
  name   = var.name
  prefix = var.prefix

  source_dir = var.source_dir
  output_dir = var.output_dir

  output_source_file = join("/", [local.output_dir, "${local.prefix}${local.name}.arhive-builder.source.zip"])

  output_build_dir  = join("/", [local.output_dir, "${local.prefix}${local.name}.archive-builder.build"])
  output_build_file = join("/", [local.output_dir, "${local.prefix}${local.name}.archive-builder.build.zip"])

  command   = var.command
  container = var.container

  local_command_count  = local.command == "" ? 0 : (local.container == "" ? 1 : 0)
  docker_command_count = local.command == "" ? 0 : (local.container == "" ? 0 : 1)

  with_command = local.local_command_count + local.docker_command_count > 0

  tags = var.tags
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.output_source_file
}

resource "null_resource" "local_command" {
  count = local.local_command_count

  triggers = {
    output_build_file_exists = fileexists(local.output_build_file)

    output_build_file = local.output_build_file
    output_build_dir  = local.output_build_dir

    command = local.command

    source_archive_file_hash = data.archive_file.source.output_base64sha256
  }

  provisioner "local-exec" {
    environment = {
      SOURCE_DIR               = local.source_dir
      OUTPUT_COMMAND_BUILD_DIR = local.output_build_dir
    }

    command = <<EOF
rm -rf "$$OUTPUT_COMMAND_BUILD_DIR"
cp -rT "$SOURCE_DIR" "$OUTPUT_COMMAND_BUILD_DIR"
EOF
  }

  provisioner "local-exec" {
    working_dir = local.output_build_dir

    environment = {
      COMMAND = local.command
    }

    command = <<EOF
/bin/sh -c "$COMMAND"
EOF
  }
}

data "archive_file" "local_command" {
  count = local.local_command_count

  type        = "zip"
  source_dir  = local.output_build_dir
  output_path = local.output_build_file

  depends_on = [
    null_resource.local_command
  ]
}

resource "null_resource" "docker_command" {
  count = local.docker_command_count

  triggers = {
    output_build_file_exists = fileexists(local.output_build_file)

    output_build_file = local.output_build_file
    output_build_dir  = local.output_build_dir

    command   = local.command
    container = local.container

    source_archive_file_hash = data.archive_file.source.output_base64sha256
  }

  provisioner "local-exec" {
    environment = {
      SOURCE_DIR               = local.source_dir
      OUTPUT_COMMAND_BUILD_DIR = local.output_build_dir
    }

    command = <<EOF
rm -rf "$$OUTPUT_COMMAND_BUILD_DIR"
cp -rT "$SOURCE_DIR" "$OUTPUT_COMMAND_BUILD_DIR"
EOF
  }

  provisioner "local-exec" {
    working_dir = local.output_build_dir

    environment = {
      CONTAINER = local.container
      COMMAND   = local.command
    }

    command = <<EOF
docker run -v "$PWD":/var/task "$CONTAINER" /bin/sh -c "$COMMAND"
EOF
  }
}

data "archive_file" "docker_command" {
  count = local.docker_command_count

  type        = "zip"
  source_dir  = local.output_build_dir
  output_path = local.output_build_file

  depends_on = [
    null_resource.docker_command
  ]
}
