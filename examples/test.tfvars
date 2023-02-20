# Drupal projects installed on production cluster.
drupal_projects_list = [
  {
    project_name                    = "stage-corporate"
    bucket_enable_disaster_recovery = false
  },
  {
    project_name                    = "test-project"
    database_name                   = "test_project_db"
    database_user_name              = "test_project_db_user"
    bucket_name                     = "test-project-bucket-name"
    bucket_append_random_suffix     = false
    bucket_enable_disaster_recovery = false
  },
]
