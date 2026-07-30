variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for the k3s cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for the nginx workload"
  type        = string
  default     = "nginx"
}

variable "nginx_image" {
  description = "Nginx container image"
  type        = string
  default     = "nginx:stable"
}

variable "replicas" {
  description = "Number of nginx replicas"
  type        = number
  default     = 1
}

variable "service_port" {
  description = "External port to expose nginx on (reachable from any IP that can reach the node)"
  type        = number
  default     = 80
}
