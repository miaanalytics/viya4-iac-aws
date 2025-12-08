# !NOTE! - These are only a subset of the variables in CONFIG-VARS.md provided
# as examples. Customize this file to add any variables from CONFIG-VARS.md whose
# default values you want to change.

# ****************  REQUIRED VARIABLES  ****************
# These required variables' values MUST be provided by the User
prefix   = "mia"
location = "il-central-1" # e.g., "us-east-1"
# ****************  REQUIRED VARIABLES  ****************

# !NOTE! - Without specifying your CIDR block access rules, ingress traffic
#          to your cluster will be blocked by default.

# **************  RECOMMENDED  VARIABLES  ***************
#cluster_endpoint_public_access_cidrs  = ["51.16.44.157/32"]                # update each time with public IP of on-prem deployment machine
default_public_access_cidrs           = []
default_private_access_cidrs          = ["10.150.0.0/16","10.0.0.0/26"]     
ssh_public_key                        = "~/.ssh/id_rsa.pub"
# **************  RECOMMENDED  VARIABLES  ***************

# Tags for all tagable items in your cluster.
tags = {} # e.g., { "key1" = "value1", "key2" = "value2" }

#-------------------CHANGED HERE-----------------
cluster_api_mode = "private"                        # for simulations (VPC peers) allow cross VPC DNS resolution in VPC peer connection properties
create_jump_vm = false                              # jump server in private mode does not install nfs-common so using the deployment-machine as the jump server as well
create_jump_public_ip = false
create_nfs_public_ip = false

vpc_id = "vpc-07e967a41f4fa145b"
subnet_ids = {
  "private" : ["subnet-0c8b455d0b4a2db3a"],
  "control_plane" : ["subnet-05e215f0499123060", "subnet-0ea45be529f94c0d6"]
}

## use EFS for private only VPC
efs_performance_mode = "maxIO"
storage_type         = "ha"
storage_type_backend = "efs"

# costs a lot of money!!
#efs_throughput_mode = "provisioned"  
#efs_throughput_rate = 1024
#-------------------CHANGED HERE-----------------

## Cluster config
kubernetes_version           = "1.28"
default_nodepool_node_count  = 1
default_nodepool_vm_type     = "m5.large"
default_nodepool_custom_data = ""

## Cluster Node Pools config - minimal
cluster_node_pool_mode = "minimal"
node_pools = {
  cas = {
    "vm_type"      = "r5.xlarge"
    "cpu_type"     = "AL2023_x86_64"
    "os_disk_type" = "gp2"
    "os_disk_size" = 200
    "os_disk_iops" = 0
    "min_nodes"    = 1
    "max_nodes"    = 1
    "node_taints"  = ["workload.sas.com/class=cas:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "cas"
    }
    "custom_data"                          = ""
    "metadata_http_endpoint"               = "enabled"
    "metadata_http_tokens"                 = "required"
    "metadata_http_put_response_hop_limit" = 1
  },
  generic = {
    "vm_type"      = "m5.2xlarge"
    "cpu_type"     = "AL2023_x86_64"
    "os_disk_type" = "gp2"
    "os_disk_size" = 200
    "os_disk_iops" = 0
    "min_nodes"    = 3
    "max_nodes"    = 5
    "node_taints"  = []
    "node_labels" = {
      "workload.sas.com/class"        = "compute"
      "launcher.sas.com/prepullImage" = "sas-programming-environment"
    }
    "custom_data"                          = ""
    "metadata_http_endpoint"               = "enabled"
    "metadata_http_tokens"                 = "required"
    "metadata_http_put_response_hop_limit" = 1
  }
}
