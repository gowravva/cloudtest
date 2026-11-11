# Stack intentionally empty.
#
# The user requested deletion of the remaining webapp-01 networking
# resources (security group, route table, internet gateway, subnet, VPC)
# directly from AWS in ap-south-1. These resources are NOT managed by
# this OpenTofu stack (they are Unmanaged / drift), so there is nothing
# for tofu to destroy here.
#
# Deletion is performed out-of-band in the following order (IGW must be
# detached from the VPC before it can be deleted; the VPC is last):
#   1. aws_security_group     webapp-01-sg
#   2. aws_route_table        webapp-01-rtb-public
#   3. aws_internet_gateway   webapp-01-igw   (detach, then delete)
#   4. aws_subnet             webapp-01-public-subnet
#   5. aws_vpc                webapp-01-vpc
#
# After the live AWS resources are gone, the Unmanaged count for this
# account/region will drop on the next scan.