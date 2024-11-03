from azure.identity import DefaultAzureCredential
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.containerservice import ContainerServiceClient
import re

# Set up the credentials and clients
subscription_id = "a35492ef-d394-49c7-9d83-77aaa06d0fc0"
credential = DefaultAzureCredential()

# Initialize the clients
network_client = NetworkManagementClient(credential, subscription_id)
container_service_client = ContainerServiceClient(credential, subscription_id)


# Helper function to extract the resource group name from the ID
def get_resource_group_from_id(resource_id):
    match = re.search(r"/resourceGroups/(?P<resource_group>[^/]+)", resource_id)
    return match.group("resource_group") if match else None


# Build a dictionary to track virtual networks and their reciprocal peerings
vnets = list(network_client.virtual_networks.list_all())
vnet_to_peering_map = {}

for vnet in vnets:
    resource_group_name = get_resource_group_from_id(vnet.id)
    peerings = network_client.virtual_network_peerings.list(resource_group_name, vnet.name)

    vnet_to_peering_map[vnet.id] = {
        "vnet": vnet,
        "peerings": {peering.remote_virtual_network.id for peering in peerings if peering.remote_virtual_network}
    }


# Function to check for reciprocal peerings
def is_reciprocal_peering(vnet_id, remote_vnet_id):
    return (
            remote_vnet_id in vnet_to_peering_map and
            vnet_id in vnet_to_peering_map[remote_vnet_id]["peerings"]
    )


# Group virtual networks with reciprocal peerings
peering_groups = {}
visited_vnets = set()


def explore_reciprocal_peering_group(vnet_id, group):
    if vnet_id in visited_vnets:
        return
    visited_vnets.add(vnet_id)
    group.append(vnet_id)
    for remote_vnet_id in vnet_to_peering_map[vnet_id]["peerings"]:
        if is_reciprocal_peering(vnet_id, remote_vnet_id):
            explore_reciprocal_peering_group(remote_vnet_id, group)


# Create groups of connected virtual networks with reciprocal peerings
for vnet_id in vnet_to_peering_map:
    if vnet_id not in visited_vnets:
        group = []
        explore_reciprocal_peering_group(vnet_id, group)
        if len(group) > 1:
            peering_groups[len(peering_groups) + 1] = group

# Fetch and display AKS clusters for each reciprocal peering group
print("Reciprocal Peering Groups:")
for group_id, vnet_ids in peering_groups.items():
    print(f"Peering Group {group_id}:")
    for vnet_id in vnet_ids:
        vnet = vnet_to_peering_map[vnet_id]["vnet"]
        resource_group_name = get_resource_group_from_id(vnet.id)
        aks_clusters = container_service_client.managed_clusters.list_by_resource_group(resource_group_name)
        for aks_cluster in aks_clusters:
            print(f"  - AKS Cluster: {aks_cluster.name} (in VNet: {vnet.name})")
    print("-" * 50)

# Identify and display isolated AKS clusters (no reciprocal peerings)
isolated_clusters = [
    vnet_id for vnet_id in vnet_to_peering_map
    if vnet_id not in visited_vnets
]

print("Isolated AKS Clusters:")
for vnet_id in isolated_clusters:
    vnet = vnet_to_peering_map[vnet_id]["vnet"]
    resource_group_name = get_resource_group_from_id(vnet.id)
    aks_clusters = container_service_client.managed_clusters.list_by_resource_group(resource_group_name)
    for aks_cluster in aks_clusters:
        print(f"  - AKS Cluster: {aks_cluster.name} (in VNet: {vnet.name})")
print("-" * 50)
