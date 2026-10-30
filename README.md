<div align="center">

# ☁️ AWS Infrastructure Provisioning with Terraform

**A VPC, public subnet, routing, security group and EC2 instance on AWS, built with one `terraform apply` and stored in an S3 remote state backend.**

![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20S3-FF9900?style=flat-square&logo=amazonaws&logoColor=white)
![AWS Provider](https://img.shields.io/badge/hashicorp%2Faws-~%3E%205.0-844FBA?style=flat-square)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

## 📌 Overview
This project provisions an AWS network and compute stack entirely with Terraform. No resources are created by clicking through the AWS Console. State is stored in an S3 backend, so it survives local machine loss and stays consistent between runs.

## 🏗️ Architecture

```mermaid
flowchart LR
    user([👤 User / SSH client]) -->|SSH :22 · HTTP :80| igw[Internet Gateway]
    subgraph aws[AWS · us-east-1]
        subgraph vpc[VPC 10.0.0.0/16]
            igw --> rt[Route table<br/>0.0.0.0/0 → IGW]
            rt --> subnet
            subgraph subnet[Public subnet 10.0.1.0/24]
                sg{{Security group<br/>22, 80 in · all out}} --- ec2[EC2 · Amazon Linux 2<br/>t2.micro]
            end
        end
        s3[(S3 bucket<br/>Terraform remote state)]
    end
    tf[[Terraform CLI]] -.->|state| s3
    tf -.->|provisions| vpc
```

| Resource | Details |
|---|---|
| **VPC** | Isolated network, CIDR `10.0.0.0/16` |
| **Public subnet** | `10.0.1.0/24`, auto-assigns public IPs |
| **Internet gateway** | Gives the VPC internet access |
| **Route table** | Sends `0.0.0.0/0` through the IGW, associated with the public subnet |
| **Security group** | Inbound SSH (22) and HTTP (80), all outbound |
| **EC2 instance** | Amazon Linux 2, `t2.micro` |
| **S3 backend** | Remote Terraform state |

## 📁 Project structure
```
terraform-aws-infra/
├── provider.tf      # AWS provider and Terraform version constraints
├── variables.tf     # Input variables (region, CIDRs, AMI, instance type, ...)
├── main.tf          # VPC, subnet, IGW, route table, security group, EC2
├── outputs.tf       # VPC ID, subnet ID, EC2 ID / public IP, SG ID
├── backend.tf       # S3 remote state backend
└── Screenshots/     # AWS Console verification
```

## 🚀 Usage

**Prerequisites:** Terraform, the AWS CLI configured with `aws configure`, and an IAM user allowed to manage VPC/EC2/S3.

> The S3 bucket in `backend.tf` must already exist. If you're using your own AWS account, change `bucket` to a bucket you own.

```bash
terraform init      # download the provider, connect to the S3 backend
terraform plan      # preview the changes
terraform apply     # create the infrastructure
terraform destroy   # tear everything down
```

After `apply`, Terraform prints these outputs:

| Output | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `subnet_id` | ID of the public subnet |
| `ec2_instance_id` | ID of the EC2 instance |
| `ec2_public_ip` | Public IP of the EC2 instance |
| `security_group_id` | ID of the security group |

## 📸 Screenshots

| EC2 instance running | VPC created |
|---|---|
| ![EC2](Screenshots/ec2-running.png) | ![VPC](Screenshots/vpc-created.png) |
| **Subnet** | **Route table** |
| ![Subnet](Screenshots/subnet-created.png) | ![Route Table](Screenshots/route-table.png) |
| **Internet gateway** | **Security group** |
| ![IGW](Screenshots/internet-gateway.png) | ![SG](Screenshots/security-group.png) |

<details>
<summary><b>S3 remote backend</b></summary>

![S3](Screenshots/s3-backend.png)

</details>

## 🛠️ Troubleshooting: orphaned route tables
**Issue:** After an incomplete `terraform destroy`, several route tables showed `Main = Yes`.

**Cause:** Terraform state was out of sync. The partial destroy left orphaned VPCs whose route tables were still the main tables.

**Fix:** Found the orphaned VPCs in the AWS Console, deleted their dependent resources manually, then ran `terraform destroy` to clean up the remaining state. The S3 remote backend now keeps state consistent between runs.

## 🔭 Possible next steps
- Restrict SSH (port 22) to a known CIDR instead of `0.0.0.0/0`, or use SSM Session Manager instead of SSH.
- Add DynamoDB state locking to the S3 backend.
- Split the code into reusable `network` and `compute` modules.
- Run `terraform fmt -check` and `terraform validate` in GitHub Actions.

## 🧰 Tech stack
Terraform · AWS VPC · EC2 · S3 · IAM · Linux

## 📄 License
[MIT](LICENSE) © Anubhav Arora
