#
# Link: https://repost.aws/knowledge-center/execute-user-data-ec2
#       https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
#       https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data
#

Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
mkfs -t xfs /dev/nvme1n1
mkdir /saswork0
mount /dev/nvme1n1 /saswork0
chmod 777 /saswork0
--//--