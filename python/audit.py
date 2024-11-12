from azure.identity import DefaultAzureCredential
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.containerservice import ContainerServiceClient
from azure_helpers import *
from data import Peering
import os
import re
import sys
import typing


# 1. Set up Azure credentials
if not (subscription_id := get_current_azure_subscription_id()):
    print("Error: 'AZURE_SUBSCRIPTION_ID' environment variable is not set or is empty.", file=sys.stderr)
    sys.exit(1)
print(f"Current Azure Subscription ID: {subscription_id}")
credential = DefaultAzureCredential()


# 2. Get the network data from Azure
with NetworkManagementClient(credential, subscription_id) as network_client, \
        ComputeManagementClient(credential, subscription_id) as vm_client:
    print("Getting networking data...\n")
    vms      = list(vm_client.virtual_machines.list_all())
    vnets    = list(network_client.virtual_networks.list_all())
    vnet_vms = dict()

    peerings = list()
    for vnet in vnets:
        # Get resource_name so we can query the Azure API:
        resource_group_name = get_resource_group_from_id(vnet.id)

        # Get network peerings:
        current_peerings = network_client.virtual_network_peerings.list(resource_group_name=resource_group_name,
                                                                virtual_network_name=vnet.name)
        for peering in current_peerings:
            peerings.append(Peering(local_vnet_address_space=vnet.address_space.address_prefixes,
                                    local_vnet_name=vnet.name,
                                    remote_vnet_address_space=peering.remote_address_space.address_prefixes,
                                    remote_vnet_name=get_virtual_network_name_from_id(peering.remote_virtual_network.id),
                                    peering_name=peering.name))

        # Get VMs that live in each network:
        vnet_vms[vnet.name] = get_vms_in_vnet(vms=vms,
                                              vnet=vnet,
                                              compute_client=vm_client,
                                              network_client=network_client)

# 3. Output the parsed connectivity info from Azure
print(f"VNet peering routes:\n--------------------------------------------------")
for i in peerings:
    print(f"- {i.local_vnet_name} ({i.local_vnet_address_space}) --> {i.remote_vnet_name} ({i.remote_vnet_address_space})")
print(f"\nIsolated VNets:\n--------------------------------------------------")
isolated_vnets = list()
for i in vnets:
    if not i.virtual_network_peerings:
        isolated_vnets.append(i)
for i in isolated_vnets:
    print(f"- {i.name} {[s.address_prefix for s in i.subnets]}")


print(f"\nMarkdown diagram:\n--------------------------------------------------")
print(f"```mermaid")
print(f"graph TD")
print(f"")
print(f"  subgraph Azure")
for i in vnets:
    print(f"    subgraph {i.name}")
    for v in vnet_vms[i.name]:
        print(f"      vm-{v}")
    if len(vnet_vms[i.name]) == 0:
        print(f"      {i.name}-placeholder[\"No VMs Found!\"]")
    print(f"    end")

for i in peerings:
    print(f"      {i.local_vnet_name} -->|{i.peering_name}| {i.remote_vnet_name}")
print(f"  end")

print(f"  %% Apply styles")
print(f"  classDef azureCloud fill:#007FFF,stroke:#004C99,stroke-width:2px,color:white;")
print(f"  class Azure azureCloud;")
print(f"```")

sys.exit()

# Build a dictionary to track virtual networks and their reciprocal peerings
vnet_to_peering_map = {}

for vnet in vnets:
    resource_group_name = get_resource_group_from_id(vnet.id)
    # Get network peerings:
    peerings = network_client.virtual_network_peerings.list(resource_group_name, vnet.name)

    vnet_to_peering_map[vnet.id] = {
        "vnet": vnet,
        "peerings": {peering.remote_virtual_network.id for peering in peerings if peering.remote_virtual_network}
    }


# Group virtual networks with reciprocal peerings
peering_groups = {}
visited_vnets = set()


# Create groups of connected virtual networks with reciprocal peerings
for vnet_id in vnet_to_peering_map:
    if vnet_id not in visited_vnets:
        group = []
        explore_reciprocal_peering_group(vnet_id, group)
        if len(group) > 1:
            peering_groups[len(peering_groups) + 1] = group

