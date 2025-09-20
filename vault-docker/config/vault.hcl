# Development Vault Configuration
# WARNING: This is for development only - NOT for production

ui = true
disable_mlock = true

storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

# Development settings
api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"