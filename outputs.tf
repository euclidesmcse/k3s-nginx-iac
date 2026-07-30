output "service_name" {
  value = kubernetes_service.nginx.metadata[0].name
}

output "external_ip" {
  description = "IP assigned by k3s ServiceLB (should match the node's LAN IP)"
  value       = try(kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip, null)
}

output "access_url" {
  value = "http://<node-ip>:${var.service_port}"
}
