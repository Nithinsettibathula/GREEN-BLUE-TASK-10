# 🚀 AWS Blue/Green Deployment for Strapi (ECS Fargate)
**Name: Nithin Settibathula** | **DevOps Intern @ Pearl Thoughts**

A complete, automated CI/CD pipeline and Infrastructure as Code (IaC) solution for deploying a highly available Strapi CMS application using a zero-downtime Blue/Green deployment strategy on AWS.

---

## 📋 Project Overview
The goal of this project was to containerize a Node.js/Strapi application and deploy it to AWS Elastic Container Service (ECS) using Fargate. To ensure high availability and zero downtime during updates, the deployment is managed by AWS CodeDeploy using a Blue/Green traffic shifting strategy via an Application Load Balancer (ALB). 

All foundational infrastructure (VPC, Subnets, RDS Database, IAM Roles) was provisioned dynamically using a modular Terraform approach.

## 🛠️ Tech Stack & Tools
* **Cloud Provider:** Amazon Web Services (AWS)
* **Infrastructure as Code:** HashiCorp Terraform
* **Containerization:** Docker & Amazon Elastic Container Registry (ECR)
* **Compute:** AWS ECS (Serverless Fargate)
* **Deployment Strategy:** AWS CodeDeploy (Blue/Green)
* **Networking:** Custom VPC, Application Load Balancer (ALB)
* **Database:** AWS RDS (PostgreSQL)
* **CI/CD Pipeline:** GitHub Actions

---

## 🏗️ Architecture & Workflow
1. **Developer Push:** Code is pushed to the `main` branch.
2. **CI Pipeline (GitHub Actions):** Authenticates with AWS, builds the Docker image, tags it with a unique SHA, and pushes it to Amazon ECR.
3. **Task Definition Update:** GitHub Actions dynamically renders the `taskdef.json` with the new image URI.
4. **CD Pipeline (CodeDeploy):** * Provisions a "Green" (replacement) task set alongside the existing "Blue" (original) task set.
   * ALB routes test traffic to the Green environment for health checks.
   * Once healthy, CodeDeploy safely shifts 100% of production traffic to the new Green environment without dropping user connections.

---

## 💡 Key Challenges & Solutions
During the development of this enterprise-grade pipeline, several real-world infrastructure and configuration blockers were successfully resolved:

* **Strict IAM Boundary Limits:** Overcame organizational IAM restrictions that prevented Terraform from creating new CloudWatch log groups by strategically re-routing container logs to existing authorized log streams in `taskdef.json`.
* **Database Driver Dependencies:** Diagnosed crashing ECS tasks by identifying that the base Strapi Docker image was missing necessary PostgreSQL drivers (`pg` module). Rebuilt the `Dockerfile` to inject the dependencies during the build phase.
* **AWS RDS SSL Certificate Rejections:** Resolved a critical Node.js `self-signed certificate in certificate chain` error by configuring Strapi environment variables (`DATABASE_SSL_REJECT_UNAUTHORIZED`) to securely accept AWS RDS encrypted connections.

---

## 📂 Modular Repository Structure
The project follows a modular and clean directory structure separating infrastructure from application code:

```text
├── .github/workflows/
│   └── deploy.yml          # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── main.tf             # Core AWS resources (VPC, ALB, ECS, RDS)
│   ├── variables.tf        # Parameterized variables
│   └── terraform.tfvars    # Environment-specific values (Subnets, VPC IDs)
├── appspec.yaml            # CodeDeploy routing instructions
├── taskdef.json            # ECS Fargate container configuration
├── Dockerfile              # Containerization instructions for Strapi
└── README.md               # Project documentation
