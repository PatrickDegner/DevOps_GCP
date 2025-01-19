## Repo for new GCP DevOps Project

$PROJECT_ID = "devops-project-448307"
gcloud auth application-default login --project $PROJECT_ID
gcloud config set project $PROJECT_ID

gcloud storage buckets create gs://${PROJECT_ID}-terraform --project $PROJECT_ID --location europe-west4


terraform init
terraform plan
terraform apply



1. gcloud init
2. gcloud container clusters create devops-gcp --zone us-west1-a --disk-type pd-standard --disk-size 15 --num-nodes 1 --machine-type e2-small
3. 