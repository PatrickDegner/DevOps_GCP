
# DEVOPS_GCP: A DevOps Project on Google Cloud Platform

This repository contains the infrastructure as code (Terraform) and application code for a sample DevOps project deployed on Google Cloud Platform (GCP). The project demonstrates a CI/CD pipeline using GitHub Actions, deploys a simple FastAPI web application on Google Kubernetes Engine (GKE), and utilizes Workload Identity Federation for secure access to GCP resources.

## Table of Contents

*   [Project Overview](#project-overview)
*   [Architecture](#architecture)
*   [Prerequisites](#prerequisites)
*   [Project Structure](#project-structure)
*   [Initial Setup (Manual)](#initial-setup-manual)
*   [Infrastructure Deployment (Terraform)](#infrastructure-deployment-terraform)
*   [GitHub Actions Setup](#github-actions-setup)
*   [Application Deployment](#application-deployment)
*   [Accessing the Application](#accessing-the-application)
*   [CI/CD Workflow](#cicd-workflow)
*   [Workload Identity Federation](#workload-identity-federation)
*   [Terraform State Management](#terraform-state-management)

## Project Overview

The `DEVOPS_GCP` project showcases a basic yet representative DevOps workflow on GCP. It includes:

1.  **A simple web application:** Built with Python's FastAPI framework, serving a basic HTML page.
2.  **Containerization:** The application is containerized using Docker.
3.  **Infrastructure as Code:** Terraform is used to define and manage the infrastructure, including:
    *   A GKE cluster for running the application.
    *   A VPC network and subnet for the cluster.
    *   An Artifact Registry repository to store Docker images.
    *   Workload Identity Federation for secure authentication of GitHub Actions.
4.  **CI/CD with GitHub Actions:** Workflows are defined to:
    *   Build and push the Docker image to Artifact Registry upon changes to the application code.
    *   Plan and apply Terraform configurations upon changes to the infrastructure code.
    *   Automatically deploy the updated application to the GKE cluster.

## Architecture

The project's architecture can be visualized as follows:

```

+-------------------------------------------------------------------------------------+
|                                   GitHub Repository                                 |
|                                     (DEVOPS_GCP)                                    |
+-------------------------------------------------------------------------------------+
^                                         |                                           ^
|   (push: app code)                      |          (push: terraform code)           |
|                                         v                                           |
|   +-----------------------------------+---------------------------------+           |
|   |          GitHub Actions           |     Application Code            |           |
|   |  (build-image.yaml,               <---+ (app.py, Dockerfile,        |           |
|   |   terraform-plan.yaml,            |     manifests/)                 |           |
|   |   terraform-apply.yaml)           |                                 |           |
|   +-----------------------------------+                                 |           |
|      |                 ^      |                                         |           |
|      |                 |      '-----------------------+                 |           |
|      v                 |                              |                 |           |
|   +--------------------+                              |                 |           |
|   | Artifact Registry  |                              |                 |           |
|   | (devops-repo)      |                              |                 |           |
|   +--------------------+                              |                 |           |
|      ^                 |                              |                 |           |
|      |                 |                              |                 |           |
|      |                 v                              |                 |           |
|      |   +------------------------+                   |                 |           |
|      |   |     GKE Cluster        |                   |                 |           |
|      |   |    (devops-cluster)    |                   |                 |           |
|      |   +------------------------+                   |                 |           |
|      |                 ^                              |                 |           |
|      |                 |                              |                 |           |
|      |                 |  (kubectl apply)             |                 |           |
|      |                 |                              v                 v           |
|      |                 +---------------+------------------------------------+       |
|      |                                 |     Terraform Code                 |       |
|      '-------------------------------> |   (main.tf, vpc.tf, container.tf,  |       |
|                                        |   federation.tf, etc.)             |       |
|                                        +------------------------------------+       |
|                                        | (Terraform Plan/Apply)                     |
|                                        v                                            |
|   +-----------------------------------------------------------------------+         |
|   |                          Google Cloud Platform                        |         |
|   |   (VPC, Subnet, GKE, Artifact Registry, Workload Identity, IAM)       |         |
|   +-----------------------------------------------------------------------+         |
+-------------------------------------------------------------------------------------+

```

*   Developers push code changes to the GitHub repository.
*   GitHub Actions are triggered based on the type of change (application or infrastructure).
*   For application changes:
    *   The `build-image.yaml` workflow builds a new Docker image.
    *   The image is pushed to Google Artifact Registry.
    *   The workflow updates the `deployment.yaml` file with the new image tag.
    *   The updated deployment is applied to the GKE cluster using `kubectl`.
*   For infrastructure changes:
    *   The `terraform-plan.yml` workflow generates a Terraform plan on pull requests.
    *   The `terraform-apply.yml` workflow applies the Terraform configuration to create or update GCP resources.
*   The GKE cluster runs the application, which is exposed via a LoadBalancer service.

## Prerequisites

Before you can start with this project, you'll need the following:

*   **A Google Cloud Platform Account:** You'll need a GCP project with billing enabled.
*   **Google Cloud SDK (gcloud):** Install the `gcloud` CLI and configure it with your project. [Installation Instructions](https://cloud.google.com/sdk/docs/install)
*   **Terraform:** Install Terraform on your local machine. [Installation Instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
*   **GitHub Account:** You'll need a GitHub account to fork this repository and set up GitHub Actions.
*   **kubectl:** Install the `kubectl` CLI for interacting with Kubernetes clusters. [Installation Instructions](https://kubernetes.io/docs/tasks/tools/)

## Project Structure

```

DEVOPS\_GCP/
├── .github/
│    └── workflows
│    ├── build-image.yaml       \# GitHub Actions workflow to build and push Docker image and deploy to GKE
│    ├── terraform-apply.yml    \# GitHub Actions workflow to apply Terraform changes
│    └── terraform-plan.yml     \# GitHub Actions workflow to generate Terraform plan
├── app/
│   │── manifests/
│   │   ├── deployment.yaml     \# Kubernetes deployment manifest
│   │   └── service.yaml        \# Kubernetes service manifest
│   │── templates/
│   │    └── index.html         \# HTML template for the FastAPI app
│   ├── app.py                  \# FastAPI application code
│   ├── Dockerfile              \# Dockerfile to build the application image
│   └── requirements.txt        \# Python dependencies
├── terraform/
│   ├── container.tf            \# Terraform code for GKE cluster and Artifact Registry
│   ├── federation.tf           \# Terraform code for Workload Identity Federation
│   ├── main.tf                 \# Main Terraform configuration
│   ├── outputs.tf              \# Terraform outputs
│   ├── providers.tf            \# Terraform provider configuration
│   ├── variables.tf            \# Terraform variables
│   ├── vpc.tf                  \# Terraform code for VPC and subnet
│   └── README.md               \# README for the Terraform code
├── .gitignore                  \# Files and folders to be ignored by Git
└── README.md                   \# This README file

````

*   **`.github/workflows/`:** Contains GitHub Actions workflow definitions.
*   **`app/`:** Contains the application code, Dockerfile, Kubernetes manifests, and HTML template.
*   **`terraform/`:** Contains the Terraform code for infrastructure management.

## Initial Setup (Manual)

1.  **Create a GCP Project:**
    *   If you don't have a GCP project already, create one in the [Google Cloud Console](https://console.cloud.google.com/).
    *   **Note:** Replace `devops-project-448307` with your actual project ID throughout this guide and in the code files.
    *   Enable billing for your project.

2.  **Fork the Repository:**
    *   Fork this repository to your own GitHub account. This will allow you to make changes and set up GitHub Actions.

3.  **Create a Terraform State Bucket:**
    *   Terraform needs a backend to store its state. We'll use a Google Cloud Storage (GCS) bucket.
    *   Run the following commands in your terminal, replacing `devops-project-448307` with your project ID:

        ```bash
        PROJECT_ID="devops-project-448307"
        gcloud auth application-default login --project $PROJECT_ID
        gcloud config set project $PROJECT_ID

        gcloud storage buckets create gs://${PROJECT_ID}-terraform --project $PROJECT_ID --location europe-west4
        ```

    *   This creates a bucket named `devops-project-448307-terraform` in the `europe-west4` region.

## Infrastructure Deployment (Terraform)

1.  **Navigate to the Terraform Directory:**

    ```bash
    cd terraform
    ```

2.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

    This downloads the necessary providers and sets up the backend (the GCS bucket you created earlier).

3.  **Plan the Infrastructure Changes:**

    ```bash
    terraform plan
    ```

    This command shows you what resources Terraform will create, modify, or destroy. Review the plan carefully.

4.  **Apply the Terraform Configuration:**

    ```bash
    terraform apply
    ```

    Type `yes` when prompted to confirm the changes. This will provision the infrastructure in your GCP project, including:
    *   VPC Network and Subnet
    *   GKE Cluster and Node Pool
    *   Artifact Registry Repository
    *   Service Account for GitHub Actions
    *   Workload Identity Pool and Provider
    *   Necessary IAM Bindings

5.  **Capture Terraform Outputs:**
    After the `terraform apply` command completes successfully, you will see output values printed to the console.
    Copy the values of `provider_name` and `service_account_github_actions_email`. For example:

    ```
    Outputs:

    pool_name = "projects/devops-project-448307/locations/global/workloadIdentityPools/github-actions-pool-id"
    provider_name = "projects/devops-project-448307/locations/global/workloadIdentityPools/github-actions-pool-id/providers/github-actions-provider-id"
    service_account_github_actions_email = "[email address removed]"
    ```

## GitHub Actions Setup

1.  **Store Terraform Outputs as GitHub Secrets:**

    *   In your forked GitHub repository, go to **Settings > Secrets and variables > Actions**.
    *   Click on "**New repository secret**"
    *   Create the following secrets:
        *   **`GCP_WORKLOAD_IDENTITY_PROVIDER_NAME`:** Paste the value of the `provider_name` output from Terraform.
        *   **`GCP_WORKLOAD_IDENTITY_SA_EMAIL`:** Paste the value of the `service_account_github_actions_email` output from Terraform.

    These secrets will be used by the GitHub Actions workflows to authenticate to GCP.

## Application Deployment

Once the infrastructure is in place and GitHub Actions are configured, the application will be automatically deployed when you push changes to the `main` branch that affect the `app` directory or the GitHub workflow files.

You can also manually trigger the `build-image.yaml` workflow from the GitHub Actions UI to deploy the application.

## Accessing the Application

1.  **Get the External IP:**
    After the deployment is successful, you can get the external IP address of the LoadBalancer service by running:

    ```bash
    kubectl get service devops-app-service -n devopsproject
    ```

    Look for the `EXTERNAL-IP` value.

2.  **Open in Browser:**
    Open your web browser and go to `http://<EXTERNAL-IP>`. You should see the "Hello from FastAPI" page.

## CI/CD Workflow

Here's how the CI/CD pipeline works:

1.  **Application Code Changes:**
    *   When you push changes to the `app` directory (or its subdirectories) or the `.github/workflows/build-image.yaml` file to the `main` branch, the `build-image.yaml` workflow is triggered.
    *   The workflow builds a new Docker image, tags it with the Git commit SHA, and pushes it to the Artifact Registry.
    *   It then updates the `app/manifests/deployment.yaml` file with the new image tag and applies the changes to the GKE cluster, effectively deploying the updated application.
    *   The Kubernetes service (`app/manifests/service.yaml`) ensures that the LoadBalancer continues to route traffic to the updated pods.

2.  **Infrastructure Code Changes (Pull Requests):**
    *   When you create a pull request that modifies files in the `terraform` directory, the `terraform-plan.yml` workflow is triggered.
    *   This workflow runs `terraform fmt`, `terraform init`, `terraform validate`, and `terraform plan`.
    *   The output of `terraform plan` is added as a comment to the pull request, allowing you to review the proposed infrastructure changes before merging.

3.  **Infrastructure Code Changes (Push to Main):**
    *   When you push changes to the `terraform` directory to the `main` branch (or merge a pull request), the `terraform-apply.yml` workflow is triggered.
    *   This workflow runs the same Terraform commands as the plan workflow but also executes `terraform apply` to apply the changes to your GCP project.
    *   It also includes a step to update the `terraform/README.md` with documentation using `terraform-docs`.

## Workload Identity Federation

This project uses Workload Identity Federation to allow GitHub Actions to authenticate to GCP without using long-lived service account keys. Here's how it works:

1.  **Terraform Configuration:** The `federation.tf` file defines:
    *   A service account (`github_actions`) that GitHub Actions will impersonate.
    *   A Workload Identity Pool (`github_actions`).
    *   A Workload Identity Provider (`github_actions`) within the pool, configured to trust tokens issued by GitHub Actions to your repository. The `attribute_condition` ensures that only tokens from your repository owner are accepted.
    *   IAM bindings to grant the service account necessary permissions (e.g. `roles/editor` to modify the infrastructure, and `roles/iam.workloadIdentityUser` to allow GitHub Actions to impersonate the service account).

2.  **GitHub Actions Authentication:** The `google-github-actions/auth@v2` action in the workflows handles the authentication process:
    *   It obtains a short-lived OpenID Connect (OIDC) token from GitHub.
    *   It exchanges this token for a Google Cloud access token using the Workload Identity Provider.
    *   It configures the `gcloud` CLI and other tools to use this access token for authentication.

## Terraform State Management

The Terraform state is stored in a GCS bucket that you created during the initial setup. The `providers.tf` file configures Terraform to use this backend:

```terraform
terraform {
  # ...

  backend "gcs" {
    bucket = "devops-project-448307-terraform" # Replace with your bucket name
    prefix = "state"
  }
}
````

  * **`bucket`:** Specifies the name of your GCS bucket.
  * **`prefix`:**  Adds a prefix to the state file path within the bucket, which can be useful for organizing state files in a shared bucket.

It is crucial to never manually modify the Terraform state file. Always use Terraform commands to make changes to your infrastructure.


**Remember to Replace Placeholders:** Update all placeholders like `devops-project-448307` with your actual project ID, repository owner, and other relevant values.
