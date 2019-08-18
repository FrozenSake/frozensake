# CI CD

This repository covers all the set-up for the CI/CD server. In this case, a gitlab implementation in GKE. This setup is based on [this guide](<https://cloud.google.com/solutions/deploying-production-ready-gitlab-on-gke>).

## How to use

1. run service-accounts.ps1 (NB: currently no equivalent shell script)
2. terraform init
3. terraform apply
4. verify everything deployed correctly

=== UNTESTED PAST HERE ===

5. run kube-setup on linux
6. (Install Helm)
7. Do the needful
