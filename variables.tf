variable "name" {
  description = "A unique name for this build."
  type        = string
}

variable "prefix" {
  description = "A unique prefix for this build."
  type        = string
  default     = ""
}

variable "source_dir" {
  description = "The source folder for the build."
  type        = string
}

variable "output_dir" {
  description = "The output directory for the build."
  type        = string
}

variable "command" {
  description = "The command to run for this build."
  type        = string
  default     = ""
}

variable "container" {
  description = "The container to run for this build. The command will be executed locally if no container provided."
  type        = string
  default     = ""
}
