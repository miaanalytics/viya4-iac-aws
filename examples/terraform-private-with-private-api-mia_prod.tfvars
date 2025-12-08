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

# Postgres config - By having this entry a database server is created. If you do not
#                   need an external database server remove the 'postgres_servers'
#                   block below.
#postgres_servers = {
#  default = {
#    "server_version"          = "15"
#    "instance_type"           = "db.m6gd.xlarge"
#    "storage_size"            = 128
#    "ssl_enforcement_enabled" = true
#    "administrator_login"     = "pgadmin"
#    "administrator_password"  = "my$up3rS3cretPassw00rd"
#  }
#}

#-------------------CHANGED HERE-----------------
cluster_api_mode = "private"                        # for simulations (VPC peers) allow cross VPC DNS resolution in VPC peer connection properties
create_jump_vm = false                              # jump server in private mode does not install nfs-common so using the deployment-machine as the jump server as well
create_jump_public_ip = false
create_nfs_public_ip = false

# if using external PG need to add two "database" subnets below as well
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
## See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-volumes.html for list of instances with internal storage
cluster_node_pool_mode = "minimal"
node_pools = {
  cas = {
    "vm_type"      = "r6id.xlarge"
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
    "custom_data"                          = "./files/custom-data/cascache_al2023.sh" # use only if instance has internal stoarge otherwise set to ""
    "metadata_http_endpoint"               = "enabled"
    "metadata_http_tokens"                 = "required"
    "metadata_http_put_response_hop_limit" = 1
  },
  compute = {
    "vm_type"      = "i4i.xlarge"             
    "cpu_type"     = "AL2023_x86_64"
    "os_disk_type" = "gp2"
    "os_disk_size" = 200
    "os_disk_iops" = 0
    "min_nodes"    = 1
    "max_nodes"    = 2
    "node_taints"  = ["workload.sas.com/class=compute:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class"        = "compute"
      "launcher.sas.com/prepullImage" = "sas-programming-environment"
    }
    "custom_data"                          = "./files/custom-data/saswork_al2023.sh" # use only if instance has internal stoarge otherwise set to ""
    "metadata_http_endpoint"               = "enabled"
    "metadata_http_tokens"                 = "required"
    "metadata_http_put_response_hop_limit" = 1
  },
  stateless = {
    "vm_type"      = "m5.2xlarge"
    "cpu_type"     = "AL2_x86_64"
    "os_disk_type" = "gp2"
    "os_disk_size" = 200
    "os_disk_iops" = 0
    "min_nodes"    = 1
    "max_nodes"    = 2
    "node_taints"  = ["workload.sas.com/class=stateless:NoSchedule"]
    "node_labels" = {}
    "custom_data"                          = ""
    "metadata_http_endpoint"               = "enabled"
    "metadata_http_tokens"                 = "required"
    "metadata_http_put_response_hop_limit" = 1
  },
  stateful = {
    "vm_type"      = "m5.2xlarge"
    "cpu_type"     = "AL2_x86_64"
    "os_disk_type" = "gp2"
    "os_disk_size" = 200
    "os_disk_iops" = 0
    "min_nodes"    = 1
    "max_nodes"    = 2
    "node_taints"  = ["workload.sas.com/class=stateful:NoSchedule"]
    "node_labels" = {}
    "custom_data"                          = ""
    "metadata_http_endpoint"               = "enabled"
    "metadata_http_tokens"                 = "required"
    "metadata_http_put_response_hop_limit" = 1
  }
}
