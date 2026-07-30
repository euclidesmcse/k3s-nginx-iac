terraform {
  required_version = ">= 1.5"

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
    type = "LoadBalancer"

    selector = {
      app = "nginx"
    }

    port {
      port        = var.service_port
      target_port = 80
    }
  }
}
