output "output_file" {
  value = ! local.with_command ? local.output_source_file : local.output_build_file
}

output "output_file_hash" {
  value = ! local.with_command ? data.archive_file.source.output_base64sha256 : (local.local_command_count > 0 ? data.archive_file.local_command.0.output_base64sha256 : data.archive_file.docker_command.0.output_base64sha256)
}
