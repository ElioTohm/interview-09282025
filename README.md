# Docker, CI, and Orchestration

This project demonstrates a CI/CD pipeline using Docker, KinD, and GitHub Actions (simulated with `act`).

## Prerequisites

Before you begin, ensure you have the following tools installed:

- **Docker:** [Installation Guide](https://docs.docker.com/get-docker/)
- **KinD (Kubernetes in Docker):** [Installation Guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- **act (Run GitHub Actions locally):** [Installation Guide](https://github.com/nektos/act#installation)

You can install `KinD` and `act` on macOS using Homebrew:

```bash
brew install kind act
```

## Getting Started

### 1. Create the Kubernetes Cluster

Run the following script to create a local KinD cluster with a container registry:

```bash
./kind-cluster.sh
```

This script will also generate a `.secrets` file containing the `kubeconfig` needed for local CI/CD runs.

### 2. Run the CI/CD Pipeline

Execute the local CI/CD pipeline using `act`:

```bash
act --secret-file=.secrets
```

The pipeline performs the following steps:

1.  **Build & Push:** Builds the Docker image and pushes it to the local registry created with the KinD cluster.
2.  **Validation:** Runs validation checks using a Python script.
3.  **Deploy:** Applies the Kubernetes manifests from the `orchestration` directory to the cluster. The image pull policy is set to `Always` for simplicity.
4.  **Verify:** Checks if the deployment was successful.

## Terraform

The `terraform` directory contains Infrastructure as Code to demonstrate best practices, including the use of modules for templating and security.

## Scripts

The `scripts` directory includes:

- A shell script for log analysis (`log-analysis.sh`) which counts IP address occurrences.
- A Go program (`scripts/golang/`) with similar functionality, including unit tests.

I have used AI to write this readme.md as for the rest was based on leveraging opensource and the community to apply best practicies which also helps with boiler place like the terraform aws modules used
looking forward for the interview for a deeper dive of the work
