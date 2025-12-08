#!/bin/bash
mkfs -t xfs /dev/nvme1n1
mkdir /saswork0
mount /dev/nvme1n1 /saswork0
chmod 777 /saswork0