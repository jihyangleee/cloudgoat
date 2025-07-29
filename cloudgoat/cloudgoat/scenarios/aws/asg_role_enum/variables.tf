variable "profile" {
  description = "The AWS profile to use."
  type        = string
  default = "default"
}

variable "region" {
  description = "The AWS region to deploy resources to."
  default     = "us-east-1"
  type        = string
}

variable "cgid" {
  description = "CloudGoat unique identifier."
  type        = string
} # 이건 따로 붙여줘야 할 듯

variable "cg_whitelist" {
  description = "User's public IP address(es)"
  type        = list(string)
}

variable "stack_name" {
  description = "Name of the stack."
  default     = "CloudGoat"
  type        = string
}

variable "scenario_name" {
  description = "Name of the scenario."
  default     = "asg_role_enum" 
  type        = string
}

