#!/bin/bash
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

    model=$(lsblk -dn -o MODEL "$dev")

    # Only EC2 Instance Store NVMe devices
    if [[ "$model" != *"Instance Storage"* ]]; then
        continue
    fi

    mkfs.xfs $dev
    mkdir $mountName$counter
    mount $dev $mountName$counter
    chmod 777 $mountName$counter

    ((counter++))

done