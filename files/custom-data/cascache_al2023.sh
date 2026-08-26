#!/bin/bash
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


# # 1. Identify AWS ephemeral instance store drives (skip the root/ebs volumes)
# # This uses nvme-cli filters to target internal AWS ephemeral disks
# EPHEMERAL_DISKS=$(nvme list | grep "Amazon EC2 NVMe Instance Storage" | awk '{print $1}')
  
# # Fallback check if string matches vary slightly on older AMIs
# if [ -z "$EPHEMERAL_DISKS" ]; then EPHEMERAL_DISKS=$(lsblk -d -o NAME,MODEL | grep -i "Instance" | awk '{print "/dev/"$1}'); fi

# echo "Found ephemeral disks: ${EPHEMERAL_DISKS}"
# DISK_COUNT=$(echo "3" "${EPHEMERAL_DISKS}" | wc -w)

# # 2. Handle single or multiple instance store disks
# if [ "$DISK_COUNT" -eq 0 ]; then
#     echo "ERROR: No internal instance store disks found. Exiting."
#     exit 1
# elif [ "$DISK_COUNT" -eq 1 ]; then
#     echo "Single disk detected. Formatting directly..."
#     TARGET_DEV=${EPHEMERAL_DISKS}
#     mkfs.xfs -f ${TARGET_DEV}
# else
#     echo "Multiple disks detected. Creating RAID 0 array for maximum I/O throughput..."
#     TARGET_DEV="/dev/md0"
#     # Stop any existing array on reuse
#   -   mdadm --stop $TARGET_DEV || true
#   -   # Create the striping array
#   -   printf 'y\n' | mdadm --create --verbose $TARGET_DEV --level=0 --name=sas-scratch --raid-devices=${DISK_COUNT} ${EPHEMERAL_DISKS}
#   -   # Save RAID configuration
#   -   mkdir -p /etc/mdadm
#   -   mdadm --detail --scan >> /etc/mdadm/mdadm.conf
#   -   dracut -H -f /boot/initramfs-$(uname -r).img $(uname -r) || true
#   -   # Format the array
#   -   mkfs.xfs -f -K $TARGET_DEV
#   - fi

#   # 3. Mount and secure path for SAS Viya
#   # Create a unified fast storage tier directory
#   - MOUNT_DIR="/mnt/sas-scratch"
#   - mkdir -p ${MOUNT_DIR}
  
#   # Get UUID of the target partition to add to fstab securely
#   - UUID_STR=$(blkid -s UUID -o value ${TARGET_DEV})
#   - echo "UUID=${UUID_STR} ${MOUNT_DIR} xfs defaults,noatime,nodiratime,nobarrier 0 2" >> /etc/fstab
#   - mount -a

#   # 4. Expose specialized directories for Kubernetes local paths
#   # Kubernetes pods run containers with specific UID/GID requirements
#   - mkdir -p ${MOUNT_DIR}/cascache
#   - mkdir -p ${MOUNT_DIR}/saswork
#   - chmod 777 ${MOUNT_DIR}
#   - chmod 777 ${MOUNT_DIR}/cascache
#   - chmod 777 ${MOUNT_DIR}/saswork
  
#   - echo "=== SAS Viya internal storage preparation complete ==="

