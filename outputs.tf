output "output_file" {
  value = local.docker_command == null ? local.output_source_file : local.output_docker_command_file
}

output "output_file_hash" {
  value = local.docker_command == null ? "A:::${data.archive_file.source.output_base64sha256}" : "A:::${data.archive_file.docker_command.0.output_base64sha256}"
}
