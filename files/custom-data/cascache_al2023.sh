#!/bin/bash

#
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
#

# 
# NOTE: NVMe device names can change when an instance restarts. 
# 

mountName="/cascache"
rootDevice=`findmnt / -o SOURCE -n`
fixedRootdevice="${rootDevice%p[0-9]*}"

counter=0

for dev in /dev/nvme[0-9]n[0-9]; do
    
    # Check if the device exists to avoid errors
    [ -e "$dev" ] || continue
    
    # Skip the fixed root device
    if [ "$dev" = "$fixedRootdevice" ]; then
        continue
    fi    

    # Only EC2 Instance Store NVMe devices
    model=$(lsblk -dn -o MODEL "$dev")
    if [[ "$model" != *"Instance Storage"* ]]; then
        continue
    fi

    mkfs.xfs $dev
    mkdir $mountName$counter
    mount $dev $mountName$counter
    chmod 777 $mountName$counter

    ((counter++))

done

# Alternative approach to mount the Instance Store NVMe 
# https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/docs/getting-started.md

# Alternative approach to mount the Instance Store NVMe devices as a DaemonSet in Kubernetes.
# https://github.com/sassoftware/project-mountpoint/blob/0e480298fe098bd7fe8bf57f75f3b486f3941cda/9-Appendix/Kubernetes/local-disk/daemonset-format-mount-local-disk.md?plain=1#L34