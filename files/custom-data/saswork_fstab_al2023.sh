#!/bin/bash

#
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
#

# 
# NOTE: NVMe device names can change when an instance restarts. 
# 

mountName="/saswork"
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

    # Format device
    mkfs.xfs -f "$dev"

    # Fetch device UUID
    uuid=$(blkid -s UUID -o value "$dev")

    # Create mount directory and mount
    mountPoint="${mountName}${counter}"
    mkdir -p "$mountPoint"
    mount "$dev" "$mountPoint"
    chmod 777 "$mountPoint"

    # Append to /etc/fstab if UUID is valid and not already present
    # Needed if the instance is restarted and the device name changes
    if [ -n "$uuid" ] && ! grep -q "$uuid" /etc/fstab; then
        echo "UUID=${uuid}  ${mountPoint}  xfs  defaults,noatime,nofail  0 2" >> /etc/fstab
    fi

    ((counter++))

done

# Alternative approach to mount the Instance Store NVMe 
# https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/docs/getting-started.md

# Alternative approach to mount the Instance Store NVMe devices as a DaemonSet in Kubernetes.
# https://github.com/sassoftware/project-mountpoint/blob/0e480298fe098bd7fe8bf57f75f3b486f3941cda/9-Appendix/Kubernetes/local-disk/daemonset-format-mount-local-disk.md?plain=1#L34