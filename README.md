# Enterprise AWS Foundation & Modular Landing Zone (Terraform)

A modular, production-grade AWS infrastructure foundation engineered with Terraform. This repository establishes a secure multi-tier network topology, automated high-availability routing, security group contracts, customer-managed KMS encryption, and IAM governance following the AWS Well-Architected Framework.

---

## 1. Network Topology & Isolation Model

The architecture enforces absolute boundary isolation across three distinct Availability Zones. Compute workloads and stateful storage are entirely detached from direct public internet exposure.

```
+---------------------------------------------------------------------------------------------------+
|                                        AWS Multi-AZ VPC                                           |
|                                                                                                   |
|  +---------------------------------------------------------------------------------------------+  |
|  | [Public Tier] - Ingress & Egress Perimeter                                                  |  |
|  | - Internet Gateway (IGW)                                                                    |  |
|  | - Public ALBs & NAT Gateways (1 per AZ when enable_nat_ha = true)                            |  |
|  +---------------------------------------------------------------------------------------------+  |
|                                                |                                                  |
|                                                v (Ingress: TCP 8080 restricted to ALB SG)         |
|  +---------------------------------------------------------------------------------------------+  |
|  | [Private Application Tier] - Scalable Compute                                               |  |
|  | - EC2 Auto Scaling Fleets & Workload Pods (No Public IP Assignment)                         |  |
|  | - Outbound traffic routed via dedicated NAT Gateways                                        |  |
|  | - Operational management enforced via AWS Systems Manager (SSM) Session Manager             |  |
|  +---------------------------------------------------------------------------------------------+  |
|                                                |                                                  |
|                                                v (Ingress: TCP 5432 restricted to App SG)         |
|  +---------------------------------------------------------------------------------------------+  |
|  | [Isolated Data Tier] - Stateful Engines                                                      |  |
|  | - Multi-AZ Amazon RDS / Database Clusters                                                   |  |
|  | - Air-Gapped: Zero IGW or NAT route table associations (Strict local subnet routing only)   |  |
|  +---------------------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Security Baselines & Compliance Controls

* **Zero Direct Compute Ingress:** Application instances are provisioned in private subnets with no public IPv4 addresses.
* **Network Access Contracts:** Security groups strictly reference parent security group identifiers instead of broad subnet IP blocks.
* **Centralized Flow Logging:** Full VPC network telemetry is captured via VPC Flow Logs and stored in an encrypted, versioned Amazon S3 bucket with public access controls fully blocked.
* **Storage Encryption:** Dedicated Customer Managed Keys (CMK) configured via AWS KMS with automatic 365-day rotation.
* **Credential-Less Management:** Bastion-free EC2 administration enabled via AWS Systems Manager (SSM) instance profiles, removing the need for static SSH keys or open inbound port 22.

---

## 3. Module Hierarchy

```
terraform-aws-enterprise-foundation/
├── modules/
│   ├── vpc/             # VPC, IGW, multi-AZ subnets, NAT Gateways, route tables
│   ├── security/        # KMS CMK, S3 Flow Logs bucket, Flow Logs, Security Groups
│   └── iam/             # EC2 IAM Role, SSM Policies, Instance Profiles
├── main.tf              # Module orchestration and data propagation
├── variables.tf         # Environment, CIDR, and availability zone controls
├── outputs.tf           # Exported identifiers and ARNs for downstream workload consumption
└── versions.tf          # Provider constraints and backend specifications
```

---

## 4. Module Interface & Inputs

### Core Input Variables (`variables.tf`)

| Variable Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `aws_region` | `string` | `"us-east-1"` | AWS Region targeted for the infrastructure. |
| `environment` | `string` | `"production"` | Environment identifier tag (`production`, `staging`). |
| `vpc_cidr` | `string` | `"10.100.0.0/16"` | Classless Inter-Domain Routing block allocated to the VPC. |
| `availability_zones` | `list(string)` | `["us-east-1a", ...]` | Target availability zones for multi-AZ resource dispersion. |
| `enable_nat_ha` | `bool` | `true` | When true, builds 1 NAT Gateway per AZ. When false, builds 1 shared NAT Gateway. |
| `custom_tags` | `map(string)` | `{}` | Custom metadata tags applied to all provisioned resources. |

### Module Outputs (`outputs.tf`)

| Output Name | Description | Downstream Target |
| :--- | :--- | :--- |
| `vpc_id` | Resource ID of the provisioned VPC. | Compute & Database configurations |
| `public_subnet_ids` | IDs of subnets in the perimeter ingress tier. | Application Load Balancers |
| `private_app_subnet_ids` | IDs of subnets in the private compute tier. | Auto Scaling Groups & Containers |
| `isolated_data_subnet_ids` | IDs of subnets in the air-gapped data tier. | RDS Subnet Groups |
| `alb_security_group_id` | Security Group ID guarding external ingress. | ALB Listeners |
| `app_security_group_id` | Security Group ID for application instances. | Launch Templates / ASGs |
| `data_security_group_id` | Security Group ID for database engines. | RDS Instances / Clusters |
| `kms_key_arn` | ARN of the infrastructure KMS CMK. | EBS Volume & S3 Bucket Encryption |
| `ec2_instance_profile_name` | IAM instance profile with SSM permissions. | Launch Template configurations |

---

## 5. Deployment Runbook

### Pre-Deployment Setup
1. Clone this repository to your local workspace or CI/CD runner.
2. Initialize and configure your parameters:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edit `terraform.tfvars` with your target AWS Region, VPC CIDR, and Availability Zones.

### Execution Commands
```bash
# Initialize Terraform and download provider plugins
terraform init

# Validate configuration syntax and structural formatting
terraform fmt -check -recursive
terraform validate

# Review proposed changes and speculative execution plan
terraform plan -out=tfplan.binary

# Apply the infrastructure convergence
terraform apply tfplan.binary
```

### Clean Up / Teardown
```bash
terraform destroy
```
