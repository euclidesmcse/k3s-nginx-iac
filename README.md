# k3s-nginx-iac

Terraform (provider [`hashicorp/kubernetes`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)) config that deploys an Nginx `Deployment` + `LoadBalancer` `Service` on the k3s cluster running on `srv01` (192.168.1.161).

Exposed on port 80, reachable from any IP that can reach the node (k3s's built-in ServiceLB assigns the node's LAN IP automatically).

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

- `main.tf` — namespace, ConfigMap (HTML content), Deployment, Service
- `variables.tf` — namespace, image, replicas, port, kubeconfig path
- `outputs.tf` — service name and external IP
- `html/index.html` — page served by Nginx (placeholder for now)
