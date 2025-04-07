variable "aws_region" {
  type = string
}

variable "spacelift_stack_id" {
  type        = string
  description = "The ID of the Spacelift stack that uses this module."
}
