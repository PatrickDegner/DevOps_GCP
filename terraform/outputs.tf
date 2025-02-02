output "pool_name" {
  description = "Pool name"
  value       = google_iam_workload_identity_pool.github_actions.name
}

output "provider_name" {
  description = "Provider name"
  value       = google_iam_workload_identity_pool_provider.github_actions.name
}

output "service_account_github_actions_email" {
  description = "Service Account used by GitHub Actions"
  value       = google_service_account.github_actions.email
}

output "cluster_endpoint" {
  value = google_container_cluster.devops_cluster.endpoint
}