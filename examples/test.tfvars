# Drupal projects installed on production cluster.
drupal_projects_list = [
  {
    gitlab_project_id               = 1
    project_name                    = "corporate"
    bucket_enable_disaster_recovery = false
    release_branch_name             = "stage"
  },
  {
    gitlab_project_id               = 2
    project_name                    = "test-project"
    database_name                   = "test_project_db"
    database_user_name              = "test_project_db_user"
    database_host                   = "cloudsqlproxy-db"
    bucket_name                     = "test-project-bucket-name"
    bucket_append_random_suffix     = false
    bucket_enable_disaster_recovery = false
  },
]
