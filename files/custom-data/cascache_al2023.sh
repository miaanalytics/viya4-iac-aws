#!/bin/bash
mkfs -t xfs /dev/nvme1n1
mkdir /cascache0
mount /dev/nvme1n1 /cascache0
chmod 777 /cascache0
