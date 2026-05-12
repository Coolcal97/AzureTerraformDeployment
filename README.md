I used to deploy cloud infrastructure by clicking through dashboards. It worked — until it didn't. Reproducing an environment for a new project meant starting from scratch every time.

So I built my first full Azure infrastructure deployment using Terraform, and the difference is night and day.

Here's what the project provisions automatically:
🔹 A Virtual Network with subnets for apps, private endpoints, and AKS
🔹 A Windows Server 2019 VM, pre-configured and ready to go
🔹 Network security rules for HTTP, HTTPS & RDP
🔹 A Load Balancer and Static Public IP for scalable traffic handling
