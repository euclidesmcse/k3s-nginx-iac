data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "kube-system"
  }
}

output "service_name" {
  value = kubernetes_service.nginx.metadata[0].name
}

output "external_ip" {
  description = "Traefik's node IP - the actual entrypoint the Ingress is served through"
  value       = try(data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].ip, null)
}

output "access_url" {
  value = "http://<node-ip>/"
}
