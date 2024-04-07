variable "flux_git_repo_url" {
  description = "URL of GitHub Repo for Flux Configuration"
  type        = string
}

variable "flux_git_repo_branch" {
  description = "Branch name for Flux Configuration"
  type        = string
  default     = "main"
}