variable "access_log_bucket" {
  default     = null
  description = "If specified, the name of the bucket where access logs should be stored. Only applicable if enable_logging is set. This should not be overridden in most cases.  Set to null to disable logging."
  type        = string
}

variable "acl" {
  default     = "private"
  description = "Allows overriding the canned ACL to use for the bucket. For private buckets the only other value that might be useful is 'log-delivery-write'; the public ACLs won't do anything with the public access block restrictions."
  type        = string
}

variable "archive_object_transition_days" {
  default     = 0
  description = "The number of days to wait transition objects in this bucket under the 'archive/' prefix or if tagged with lifecycle='archive'.  After this time S3 will transition these objects to GlacierIR.  Set to 0 to disable archive object rules."
  type        = number
  validation {
    condition     = var.archive_object_transition_days >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "bucket_metrics_filters" {
  description = "A map of S3 bucket metrics named filters for emitting S3 storage and request metrics to CloudWatch."
  default     = {}
  type = map(object({
    prefix = optional(string)
  }))
}

variable "cold_tier_minimum_size" {
  default     = 1048576
  description = "The minimum size in bytes required to transition an object to cold storage.  Must be >=131072 (128 KiB).  Recommend >=1048576 (1MiB)."
  type        = number
  validation {
    condition     = var.cold_tier_minimum_size >= 131072
    error_message = "Accepted values: >=131072."
  }
}

variable "cold_tier_storage_class" {
  default     = "GLACIER_IR"
  description = "The S3 storage class to transition objects to when cold_tier_transition_days is >0.  GLACIER_IR only; use DEEP_ARCHIVE for offline archiving."
  type        = string
  validation {
    condition     = can(regex("^(GLACIER_IR|DEEP_ARCHIVE)$", var.cold_tier_storage_class))
    error_message = "Invalid input, specify either \"GLACIER_IR\" or \"DEEP_ARCHIVE\"."
  }
}

variable "cold_tier_transition_days" {
  default     = 0
  description = "The number of days to wait to transition objects to the cold_tier_storage_class.  Set to 0 to disable transition to a cold tier."
  type        = number
  validation {
    condition     = var.cold_tier_transition_days >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "context" {
  description = "A context passed from the calling repo's label module. These will override duplicate tags."
  type        = any
}

variable "disable_required_tag_checks" {
  default     = false
  description = "Set to 'true' to disable checks for compliance with required tags."
  type        = bool
}

variable "dr_access_log_bucket" {
  default     = null
  description = "S3 bucket in DR region for access logging. Must be in the same region as the DR bucket. Set to null to disable logging on DR bucket. Only used when dr_enabled is true."
  type        = string
}

variable "dr_bidirectional" {
  default     = false
  description = "Enable bidirectional replication between primary and DR buckets. When true, changes in either bucket replicate to the other. Only used when dr_enabled is true."
  type        = bool
}

variable "dr_bucket_name_override" {
  default     = null
  description = "Override the DR bucket name. If null, defaults to '{primary-bucket-name}-dr'. Use this for existing DR buckets with custom names. Only used when dr_enabled is true."
  type        = string
}

variable "dr_bucket_name_prefix" {
  default     = null
  description = "Override the DR bucket name prefix. If null, uses the same prefix as the primary bucket. Only used when dr_enabled is true."
  type        = string
}

variable "dr_enabled" {
  default     = false
  description = "Set to true to enable disaster recovery by creating a replica bucket in the DR region and configuring cross-region replication."
  type        = bool
}

variable "dr_kms_master_key_id" {
  default     = null
  description = "When specified, the DR bucket will use this KMS key for encryption. If null, the DR bucket will use S3 AES256 encryption. Only used when dr_enabled is true."
  type        = string
}

variable "dr_mrap_enabled" {
  default     = false
  description = "Create a Multi-Region Access Point (MRAP) that includes both the primary and DR buckets for automatic failover. Only used when dr_enabled is true."
  type        = bool
}

variable "dr_mrap_name" {
  default     = null
  description = "The name for the DR Multi-Region Access Point. If null, defaults to '{bucket-name}-mrap'. Only used when dr_enabled and dr_mrap_enabled are true."
  type        = string
}

variable "dr_mrap_policy_name" {
  default     = null
  description = "Custom name for the MRAP IAM policy. If null, defaults to '{name}{suffix}-mrap-policy'. Only used when dr_enabled and dr_mrap_enabled are true."
  type        = string
}

variable "dr_mrap_role_name" {
  default     = null
  description = "Custom name for the MRAP IAM role. If null, defaults to '{name}{suffix}-mrap-role'. Only used when dr_enabled and dr_mrap_enabled are true."
  type        = string
}

# NEW: MRAP routing Lambda control-plane Region
variable "dr_mrap_control_plane_region" {
  type        = string
  default     = "us-east-1"
  description = "S3 MRAP control plane region used by the routing Lambda."
}

# NEW: MRAP routing Lambda package path
variable "dr_mrap_lambda_package_path" {
  type        = string
  description = "Path to ZIP file for the MRAP routing Lambda (Python)."
}

variable "dr_region" {
  default     = "us-east-2"
  description = "The AWS region where the DR bucket will be created. Only used when dr_enabled is true."
  type        = string
}

variable "dr_replicate_delete_markers" {
  default     = true
  description = "Whether to replicate delete markers to the DR bucket. Only used when dr_enabled is true."
  type        = bool
}

variable "dr_replication_policy_name" {
  default     = null
  description = "Custom name for the replication IAM policy. If null, defaults to '{name}{suffix}-replication-policy'. Only used when dr_enabled is true."
  type        = string
}

variable "dr_replication_role_name" {
  default     = null
  description = "Custom name for the replication IAM role. If null, defaults to '{name}{suffix}-replication-role'. Only used when dr_enabled is true."
  type        = string
}

variable "dr_replication_time_control" {
  default     = false
  description = "Enable S3 Replication Time Control (RTC) for predictable replication time (99.99% of objects replicated within 15 minutes). Only used when dr_enabled is true."
  type        = bool
}

variable "dr_storage_class" {
  default     = "STANDARD"
  description = "The storage class for replicated objects in the DR bucket. Options: STANDARD, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, DEEP_ARCHIVE."
  type        = string
  validation {
    condition     = can(regex("^(STANDARD|STANDARD_IA|ONEZONE_IA|INTELLIGENT_TIERING|GLACIER_IR|GLACIER|DEEP_ARCHIVE)$", var.dr_storage_class))
    error_message = "Invalid input, options: \"STANDARD\", \"STANDARD_IA\", \"ONEZONE_IA\", \"INTELLIGENT_TIERING\", \"GLACIER_IR\", \"GLACIER\", \"DEEP_ARCHIVE\"."
  }
}

variable "force_destroy" {
  default     = false
  description = "CAUTION: Setting this to true will cause all data in your bucket to be deleted when terraform attempts to delete the bucket."
  type        = bool
}

variable "incomplete_multipart_expiration_days" {
  default     = 7
  description = "The number of days after initiation to wait to expire parts of an incomplete multipart upload. Set to 0 retain parts indefinitely."
  type        = number
  validation {
    condition     = var.incomplete_multipart_expiration_days >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "kms_master_key_id" {
  default     = null
  description = "When specified, new objects will be encrypted using the specified KMS key and the sse_algorithm will be set to aws:kms, otherwise AES256."
  type        = string
}

variable "lifecycle_rules" {
  description = "A list of S3 lifecycle rules for transitioning and/or expiring objects within the bucket based on prefixes and tags."
  default     = []
  type = list(object({
    id     = string
    status = string
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))
    filter = optional(object({
      prefix = optional(string)
      tag = optional(object({
        key   = string
        value = string
      }))
      and = optional(object({
        prefix                   = optional(string)
        tags                     = optional(map(string))
        object_size_greater_than = optional(number)
        object_size_less_than    = optional(number)
      }))
      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
    }))
    noncurrent_version_transitions = optional(list(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
      storage_class             = string
    })))
    transitions = optional(list(object({
      date         = optional(string)
      days         = optional(number)
      storage_class = string
    })))
  }))
}

variable "mrap_iam" {
  default     = null
  description = "IAM role and policy configuration for S3 Multi-Region Access Point. Set to null to disable IAM creation."
  type = object({
    role_name                    = string
    policy_name                  = string
    policy_path                  = optional(string, "/")
    policy_description           = optional(string, "IAM policy for S3 Multi-Region Access Point")
    mrap_arn                     = optional(string)
    bucket_arns                  = optional(list(string), [])
    custom_role_trust_policy     = optional(string)
    custom_policy                = optional(string)
    additional_policy_statements = optional(list(any), [])
  })
}

variable "mrap_name" {
  default     = null
  description = "The name of the multi-region access point. Set to null to disable multi-region access point creation."
  type        = string
}

variable "mrap_regions" {
  default     = []
  description = "A list of regions and bucket ARNs to create multi-region access points for. Set to empty list to disable multi-region access point creation."
  type        = list(object({ region = string, bucket_arn = string }))
}

variable "name" {
  description = "The name of the bucket, WITHOUT the 'hingehealth' prefix."
  type        = string
}

variable "name_prefix" {
  default     = "hingehealth-"
  description = "A prefix for the name of the bucket. This is defined as a variable so that most buckets can share a default prefix."
  type        = string
}

variable "name_uniqueness" {
  default     = false
  description = "Assigns a random suffix (exa: -588b75a3) to the 'name' so that more than one instance of the same logical bucket can exist globally."
  type        = bool
}

variable "noncurrent_object_expiration_days" {
  default     = 7
  description = "The number of days until non-current S3 objects in the bucket expire. Set to 0 retain non-current versions indefinitely."
  type        = number
  validation {
    condition     = var.noncurrent_object_expiration_days >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "object_expiration_days" {
  default     = 0
  description = "Expire any objects in the bucket older than the specified number of days. Set to 0 to retain current objects indefinitely."
  type        = number
  validation {
    condition     = var.object_expiration_days >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "object_lock_default_retention_period" {
  default     = 0
  description = "When object_lock_enabled is true, the time in object_lock_default_retention_units that objects written to this bucket will remain locked in governance mode by default."
  type        = number
  validation {
    condition     = var.object_lock_default_retention_period >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "object_lock_default_retention_units" {
  default     = "Days"
  description = "The units (days or years) that the object_lock_default_retention_period represents."
  type        = string
  validation {
    condition     = can(regex("^(Days|Years)$", var.object_lock_default_retention_units))
    error_message = "Invalid input, options: \"Days\", \"Years\"."
  }
}

variable "object_lock_enabled" {
  default     = false
  description = "Enables object written to this bucket to be locked from deletion by the object writer using S3 Object Lock."
  type        = bool
}

variable "object_ownership" {
  default     = "BucketOwnerPreferred"
  description = "BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter control object ownership."
  type        = string
  validation {
    condition     = can(regex("^(BucketOwnerPreferred|BucketOwnerEnforced|ObjectWriter)$", var.object_ownership))
    error_message = "Invalid input, options: \"BucketOwnerEnforced\", \"BucketOwnerPreferred\", \"ObjectWriter\"."
  }
}

variable "object_versioning_status" {
  default     = "Enabled"
  description = "Versioning on the bucket can either be 'Enabled' or 'Suspended'."
  type        = string
  validation {
    condition     = can(regex("^(Enabled|Suspended)$", var.object_versioning_status))
    error_message = "Invalid input, options: \"Enabled\", \"Suspended\"."
  }
}

variable "policy" {
  description = "Optional bucket policy."
  type        = string
  default     = ""
}

variable "private" {
  default     = true
  description = "Set to false to allow public-read ACLs on objects in this bucket."
  type        = string
}

variable "replication_configuration" {
  description = "S3 bucket replication configuration. Set to null to disable replication. If iam_role_arn is null and replication_iam is enabled, will use the created IAM role."
  type = object({
    iam_role_arn = optional(string)
    rules = list(object({
      id                               = string
      status                           = string
      priority                         = optional(number)
      delete_marker_replication_status = string
      destinations = list(object({
        bucket_arn    = string
        storage_class = optional(string, "STANDARD")
        account_id    = optional(string)
        access_control_translation = optional(object({
          owner = string
        }))
        encryption_configuration = optional(object({
          replica_kms_key_id = string
        }))
        metrics = optional(object({
          status                  = string
          event_threshold_minutes = number
        }))
        replication_time = optional(object({
          status       = string
          time_minutes = number
        }))
      }))
      filter = optional(object({
        prefix = optional(string, "")
        tag = optional(object({
          key   = string
          value = string
        }))
        and = optional(object({
          prefix = optional(string)
          tags   = optional(map(string))
        }))
      }))
      source_selection_criteria = optional(object({
        sse_kms_encrypted_objects = optional(object({
          status = string
        }))
        replica_modifications = optional(object({
          status = string
        }))
      }))
      existing_object_replication = optional(object({
        status = string
      }))
    }))
    depends_on = optional(list(any), [])
  })
  default = null
}

variable "replication_iam" {
  description = "IAM role and policy configuration for S3 replication. Set to null to disable IAM creation."
  type = object({
    role_name                    = string
    policy_name                  = string
    policy_path                  = optional(string, "/")
    policy_description           = optional(string, "IAM policy for S3 replication")
    destination_bucket_arns      = optional(list(string), [])
    custom_role_trust_policy     = optional(string)
    custom_policy                = optional(string)
    additional_policy_statements = optional(list(any), [])
  })
  default = null
}

variable "tags" {
  default     = {}
  description = "A map of resource-specific tags that is combined with and will be overridden by those passed in via context."
  type        = map(string)
}

variable "temporary_object_expiration_days" {
  default     = 0
  description = "The number of days until objects expire in this bucket under the 'temporary/' prefix or if tagged with lifecycle='temporary'."
  type        = number
  validation {
    condition     = var.temporary_object_expiration_days >= 0
    error_message = "Accepted values: >=0."
  }
}

variable "warm_tier_minimum_size" {
  default     = 131072
  description = "The minimum size in bytes required to transition an object to warm storage."
  type        = number
  validation {
    condition     = var.warm_tier_minimum_size >= 131072
    error_message = "Accepted values: >=131072."
  }
}

variable "warm_tier_storage_class" {
  default     = "STANDARD_IA"
  description = "The S3 storage class to transition objects to when warm_tier_transition_days is >0 for INTELLIGENT_TIERING or >=30 for STANDARD_IA."
  type        = string
  validation {
    condition     = can(regex("^(INTELLIGENT_TIERING|STANDARD_IA)$", var.warm_tier_storage_class))
    error_message = "Invalid input, specify either \"INTELLIGENT_TIERING\" or \"STANDARD_IA\" with warm_tier_transition_days >= 30."
  }
}

variable "warm_tier_transition_days" {
  default     = 0
  description = "The number of days to wait to transition objects to the warm_tier_storage_class.  Set to 0 to disable transition to a warm tier."
  type        = number
  validation {
    condition     = var.warm_tier_transition_days >= 0
    error_message = "Accepted values: >=0."
  }
}
