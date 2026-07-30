# k3s-nginx-iac

Terraform (provider [`hashicorp/kubernetes`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)) config that deploys an Nginx `Deployment` on the k3s cluster running on `srv01` (192.168.1.161), exposed through an `Ingress`.

k3s ships Traefik as its default ingress controller, already bound to host ports 80/443. Routing through an Ingress (instead of a second `LoadBalancer` Service, which would fail to schedule — port 80 is already claimed by Traefik) makes nginx reachable on port 80 from any IP that can reach the node.

## Landing page

`html/index.html` is mounted into the container via a `ConfigMap`, replacing Nginx's default page. To publish the real landing page later, replace the contents of `html/index.html` and run `terraform apply` again — no image rebuild needed.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Access: `http://192.168.1.161` (or the IP shown in the `external_ip` output).

## Layout

- `main.tf` — namespace, ConfigMap (HTML content), Deployment, Service, Ingress
- `variables.tf` — namespace, image, replicas, port, kubeconfig path
- `outputs.tf` — service name and Traefik's node IP
- `html/index.html` — page served by Nginx (placeholder for now)
