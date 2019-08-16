# This script is expected to run from a subdirectory of the main project, and expects the main project to have the same name as the GCopy-Item project.
Push-LoGet-Contention ..
$env:PROJECT_ID = Split-Path -Path $PWD -Leaf
$env:REGION     = 'northamerica-northeast1'
$env:ZONE       = 'northamerica-northeast1-a'
$env:NETWORK    = 'default'
$env:PASSWORD   = openssl rand -base64 18
Pop-LoGet-Contention

gcloud auth login

gcloud services enable container.googleapis.com
       servicenetworking.googleapis.com
       cloudresourcemanager.googleapis.com
       redis.googleapis.com

gcloud components install kubectl

gcloud iam service-accounts create gitlab-gcs `
    --display-name "GitLab Cloud Storage"
gcloud iam service-accounts keys create --iam-account `
    gitlab-gcs@$env:PROJECT_ID.iam.gserviceaccount.com gcs-key.json
gcloud projects add-iam-policy-binding --role roles/storage.admin $env:PROJECT_ID `
    --member=serviceAccount:gitlab-gcs@$env:PROJECT_ID.iam.gserviceaccount.com

gsutil mb gs://$env:PROJECT_ID-uploads
gsutil mb gs://$env:PROJECT_ID-artifacts
gsutil mb gs://$env:PROJECT_ID-lfs
gsutil mb gs://$env:PROJECT_ID-packages
gsutil mb gs://$env:PROJECT_ID-registry

gcloud compute addresses create gitlab --region $env:REGION `
    --description "Gitlab Ingress IP"

gcloud compute addresses create gitlab-sql --global --prefix-length 20 `
    --description="Gitlab Cloud SQL range" --network=$env:NETWORK
gcloud beta services vpc-peerings connect `
    --service=servicenetworking.googleapis.com --ranges=gitlab-sql `
    --network=$env:NETWORK --project $env:PROJECT_ID

gcloud beta sql instances create gitlab-db --network $env:NETWORK `
    --database-version=POSTGRES_9_6 --Copy-Itemu 4 --memory 15 --no-assign-ip `
    --storage-auto-increase --zone $env:ZONE

gcloud sql users create gitlab --instance gitlab-db --password $env:PASSWORD

gcloud sql databases create --instance gitlab-db gitlabhq_production

gcloud redis instances create gitlab --size=2 --region=$env:REGION `
    --zone=$env:ZONE --tier standard

gcloud container clusters create gitlab --machine-type n1-standard-4 `
    --zone $env:ZONE --enable-ip-alias

kubectl apply -f pd-ssd-storage.yaml

kubectl create secret generic gitlab-pg --from-literal=password=$env:PASSWORD

kubectl create secret generic google-appliGet-Contention-credentials `
    --from-file=gcs-appliGet-Contention-credentials-file=./gcs-key.json

kubectl create secret generic gitlab-rails-storage --from-file=connection=rails.yaml

Invoke-WebRequest https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz

tar zxfv helm-v2.12.3-linux-amd64.tar.gz
Copy-Item linux-amd64/helm .

kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding `
    --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

./helm init --service-account=tiller
./helm update

./helm version

Invoke-WebRequest https://raw.githubusercontent.com/terraform-google-modules/terraform-google-gke-gitlab/master/values.yaml.tpl

export PROJECT_ID=$(gcloud config get-value project)
export INGRESS_IP=$(gcloud compute addresses describe gitlab `
    --region us-central1 --format 'value(address)')
export DB_PRIVATE_IP=$(gcloud sql instances describe gitlab-db `
    --format 'value(ipAddresses[0].ipAddress)')
export REDIS_PRIVATE_IP=$(gcloud redis instances describe gitlab `
    --region=us-central1  --format 'value(host)')
export CERT_MANAGER_EMAIL=$(gcloud config get-value account)

Get-Content values.yaml.tpl | envsubst > values.yaml

./helm repo add gitlab https://charts.gitlab.io/
./helm install -f values.yaml --version 1.7.1 -n gitlab gitlab/gitlab

git clone https://github.com/stackdriver/stackdriver-prometheus-sidecar
Set-LoGet-Contention stackdriver-prometheus-sidecar/kube/full

export KUBE_NAMESPACE=default
export KUBE_CLUSTER=gitlab
export GCopy-Item_REGION=us-central1
export GCopy-Item_PROJECT=$(gcloud config get-value project)
export SIDECAR_IMAGE_TAG=release-0.4.2

./deploy.sh

export GITLAB_HOSTNAME=$(kubectl get ingresses.extensions gitlab-unicorn `
    -o jsonpath='{.spec.rules[0].host}')
Write-Output "Your GitLab URL is: https://${GITLAB_HOSTNAME}"

kubectl get pods