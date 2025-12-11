# ResiliNet: Multi Region Disaster Recovery System

![ResiliNet Architecture Diagram](https://mahdi-readme-images.s3.us-east-1.amazonaws.com/ResiliNetDiagram.jpg)

## Project Overview

**ResiliNet** is a high availability infrastructure project that demonstrates how to keep a web application running even if an entire AWS region goes offline. It uses an **Active Passive failover** strategy to automatically reroute traffic from the US to Europe in less than 60 seconds during an outage.

### Key Achievements

*   **Automated Failover:** Implemented a failover strategy using **Amazon Route 53 Health Checks** to continuously monitor endpoint latency. In the event of an outage in the primary region (US East 1), traffic is automatically rerouted to the standby region (EU West 1) without human intervention.
*   **Fault Tolerant Data Layer:** Engineered a resilient backend achieving sub minute RTO by implementing DNS Failover policies backed by **DynamoDB Global Tables**. This ensures that critical user data is replicated active active across regions and is instantly available upon failover.
*   **Infrastructure as Code (IaC):** Fully automated the provisioning of multi region infrastructure using **Terraform**. This approach eliminates configuration drift and ensures that the standby environment is an exact replica of the primary, utilizing multi provider aliases and state locking for consistency.

## Architecture Explained

The system is built on a "Global Traffic Manager" pattern. Here is how the components interact to ensure uptime:

1.  **User Entry:** All traffic enters through a single global domain managed by **Route 53**.
2.  **Health Monitoring:** Route 53 acts as the brain, constantly pinging the Primary Region (US) to ensure it is returning a healthy `200 OK` status.
3.  **Normal Operation:** As long as the US region is healthy, Route 53 directs all user traffic there.
4.  **Failure Scenario:** If the US region goes down (simulated by a 404 or 500 error), Route 53 detects the failure within seconds and updates its DNS answer to point users to the Secondary Region (EU).
5.  **Data Consistency:** Behind the scenes, **S3 Cross Region Replication** keeps static assets synced, while **DynamoDB Global Tables** replicate database writes in near real time, ensuring users see the same data regardless of which region serves them.

## Technical Stack

*   **Cloud Provider:** Amazon Web Services (AWS)
*   **Infrastructure as Code:** Terraform (HCL)
*   **DNS & Networking:** Amazon Route 53 (Failover Routing, Health Checks)
*   **Storage:** Amazon S3 (Versioning, Cross Region Replication)
*   **Database:** Amazon DynamoDB (Global Tables)

## How to Deploy

This project is built to be easily replicated. You will need an AWS account, the AWS CLI configured, and Terraform installed.

### 1. Initialize
Clone the repository and initialize the Terraform plugins:
```bash
git clone https://github.com/Mahdi-196/ResiliNet
cd ResiliNet
terraform init
```

### 2. Configure
Update the `terraform.tfvars` file with your specific domain name and preferred regions:
```hcl
domain_name = "your-domain.com"
primary_region = "us-east-1"
secondary_region = "eu-west-1"
```

### 3. Deploy
Review the plan and provision the infrastructure:
```bash
terraform plan
terraform apply
```
*Note: This script deploys resources to two different AWS regions simultaneously.*

### 4. Verify & Test (Chaos Engineering)
Once deployed, access your domain to see the primary site. To verify the disaster recovery capabilities:
1.  Manually "break" the primary site by deleting the `index.html` file from the US bucket.
2.  Wait approx. 60 seconds for the Health Check to fail.
3.  Refresh your browser. You will be automatically routed to the EU region, proving the failover logic works.

### 5. Cleanup
To avoid ongoing AWS costs, destroy the infrastructure when finished:
```bash
terraform destroy
```
