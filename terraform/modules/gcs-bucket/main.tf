resource "google_storage_bucket" "this" {
    name = var.name
    project = var.project_id
    location = var.location

    uniform_bucket_level_access = var.unform_bucket_level_access
    public_access_prevention    = var.public_access_prevention
    force_destroy               = var.force_destroy
    storage_class               = var.autoclass_enabled ? null : var.storage_class

    autoclass {
        enabled                 = var.autoclass_enabled
        terminal_storage_class  = var.autoclass_terminal_storage_class
    }

    versioning {
        enabled = var.versioning_enabled
    }

    dynamic "lifecycle_rule" {
        for_each = var.lifecycle_rules
        content {
            action {
                type          = lookup(lifecycle_rule.value.action, "type", null)
                storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
            }

            condition {
                age                     = lookup(lifecycle_rule.value.condition, "age", null)
                created_before          = lookup(lifecycle_rule.value.condition, "created_before", null)
                with_state              = lookup(lifecycle_rule.value.condition, "with_state", null)
                num_newer_versions      = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
                matches_storage_class   = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
            }
        }
    }

    labels = merge(
        {
            managed = "terraform"
            module = "gcs-bucket"
        },
        var.labels
    )
}

resource "google_storage_bucket_iam_member" "this" {
    for_each = {
        for i, m in var.iam_members : i => m
    }

    bucket = google_storage_bucket.this.name
    role   = each.value.role
    member = each.value.member
}

resource "google_storage_notification" "this" {
    count = var.notification ? 1 : 0
    bucket = google_storage_bucket.this.name
    topic  = var.notification.topic
    payload_format = coalesce(var.notification.payload_format, "JSON_API_V1")
    event_types   = coalesce(var.notification.event_types, ["OBJECT_FINALIZE"])
    object_name_prefix = lookup(var.notification, "object_name_prefix", null)
}