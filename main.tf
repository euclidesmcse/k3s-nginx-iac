terraform {
  required_version = ">= 1.5"

  # Local backend at a fixed, absolute path so both manual `terraform apply`
  # runs and the self-hosted GitHub Actions runner (which checks out into a
  # different, ephemeral workspace) share the same state on srv01.
  backend "local" {
    path = "/home/euclides/.terraform-state/k3s-nginx-iac.tfstate"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "nginx_html" {
  metadata {
    name      = "nginx-html"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  data = {
    "index.html" = file("${path.module}/html/index.html")
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.nginx_image

          port {
            container_port = 80
          }

          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html"
          config_map {
            name = kubernetes_config_map.nginx_html.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "nginx"
    }

    port {
      port        = var.service_port
      target_port = 80
    }
  }
}

# k3s ships Traefik as its default ingress controller, already bound to
# host ports 80/443 via its own LoadBalancer service. Routing through an
# Ingress (instead of a second LoadBalancer Service) avoids competing for
# those ports and makes nginx reachable on http://<node-ip>/ from any IP.
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.nginx.metadata[0].name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}
