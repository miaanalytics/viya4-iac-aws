#!/bin/bash
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

    mkfs -t xfs $dev
    mkdir /cascache$counter
    mount $dev /cascache$counter
    chmod 777 /cascache$counter

    ((counter++))

done
