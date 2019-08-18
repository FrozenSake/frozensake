# This script is expected to run from a subdirectory of the main project, and expects the main project to have the same name as the GCopy-Item project.
Push-Location ..
$env:PROJECT_ID = Split-Path -Path $PWD -Leaf
Pop-Location

gcloud auth login

gcloud services enable container.googleapis.com `
        servicenetworking.googleapis.com `
        cloudresourcemanager.googleapis.com `
        redis.googleapis.com
        cloudsql.googleapis.com

gcloud components install kubectl

gcloud iam service-accounts create gitlab-terraform `
    --display-name "GitLab Terraformer"
gcloud iam service-accounts keys create --iam-account `
    gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com ./terraform-key.json
gcloud projects add-iam-policy-binding --role roles/storage.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding --role roles/compute.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding --role roles/redis.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding --role roles/container.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding --role roles/iam.serviceAccountUser $env:PROJECT_ID `
    --member=serviceAccount:gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding --role roles/cloudsql.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-terraform@$env:PROJECT_ID.iam.gserviceaccount.com

gcloud iam service-accounts create gitlab-gcs `
    --display-name "GitLab Cloud Storage"
gcloud iam service-accounts keys create --iam-account `
    gitlab-gcs@$env:PROJECT_ID.iam.gserviceaccount.com ./gcs-key.json
gcloud projects add-iam-policy-binding --role roles/storage.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-gcs@$env:PROJECT_ID.iam.gserviceaccount.com