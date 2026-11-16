terraform {
  backend "s3" {
    bucket       = "cloudagentra-state-444062204915-test-gouri"
    key          = "cloudagentra/compute/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }

  encryption {
    key_provider "pbkdf2" "mykey" {
      passphrase = var.tofu_state_passphrase
    }

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.mykey
    }

    method "unencrypted" "off" {}

    state {
      method = method.unencrypted.off

      fallback {
        method = method.aes_gcm.default
      }
    }

    plan {
      method = method.unencrypted.off

      fallback {
        method = method.aes_gcm.default
      }
    }
  }
}

variable "tofu_state_passphrase" {
  type      = string
  sensitive = true
}
