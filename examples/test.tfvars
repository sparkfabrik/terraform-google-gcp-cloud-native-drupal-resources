# Drupal projects installed on production cluster.
my_drupal_projects_list = [
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
    bucket_labels = {
      "project" = "test-project"
      "env"     = "stage"
    }
    bucket_tag_list = ["dev/editor", "ops/admin"]
    bucket_obj_vwr = [
      "group:test-gcp-ops@test.example.com",
      "user:test-gcp-ops-user@test.example.com",
    ]
  },
]
