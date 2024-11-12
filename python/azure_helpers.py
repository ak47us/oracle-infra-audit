from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
import re
import subprocess
import sys


def get_current_azure_subscription_id():
    """ Get the current Azure subscription ID by executing an Azure CLI command."""
    try:
        # Execute the Azure CLI command to get the current subscription ID
        result = subprocess.run(
            ["az", "account", "show", "--query", "id", "--output", "tsv"],
            capture_output=True,
            text=True,
            check=True
        )
        subscription_id = result.stdout.strip()
        if not subscription_id:
            raise ValueError("The Azure subscription ID is empty.")
        return subscription_id
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to retrieve Azure subscription ID. {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def get_resource_group_from_id(resource_id: str) -> str:
    """Extract the resource group name from the ID"""
    # captures all characters following /resourceGroups/ until the next / or end of the string:
    match = re.search(r"/resourceGroups/(?P<resource_group>[^/]+)", resource_id)
    return match.group("resource_group") if match else None


def get_virtual_network_name_from_id(resource_id: str) -> str:
    """Extract the resource group name from the ID"""
    # captures all characters following /resourceGroups/ until the next / or end of the string:
    match = re.search(r"virtualNetworks/(?P<virtual_network_name>[^/]+)", resource_id)
    return match.group("virtual_network_name") if match else None


def get_vms_in_vnet(vms: list,
                    vnet,
                    compute_client: ComputeManagementClient,
                    network_client: NetworkManagementClient) -> list:
    """Get a list of VMs that are inside a VNet, using the Azure Library."""
    subnet_ids = [subnet.id for subnet in vnet.subnets]

    vms_in_vnet = []

    for vm in vms:
        # Get the network interfaces for the VM
        nic_refs = vm.network_profile.network_interfaces
        for nic_ref in nic_refs:
            nic_name = nic_ref.id.split('/')[-1]
            nic_rg = nic_ref.id.split('/')[4]  # Resource group of the NIC

            # Get NIC details
            nic = network_client.network_interfaces.get(nic_rg, nic_name)

            # Check if NIC is in one of the VNet's subnets
            for ip_config in nic.ip_configurations:
                if ip_config.subnet.id in subnet_ids:
                    vms_in_vnet.append(vm.name)
                    break
    return vms_in_vnet

# def is_reciprocal_peering(vnet_id: str, remote_vnet_id:str ) -> bool:
#     """Check for reciprocal peerings"""
#     return (
#             remote_vnet_id in vnet_to_peering_map and
#             vnet_id in vnet_to_peering_map[remote_vnet_id]["peerings"]
#     )


def explore_reciprocal_peering_group(vnet_id: str, group: list):
    if vnet_id in visited_vnets:
        return
    visited_vnets.add(vnet_id)
    group.append(vnet_id)
    for remote_vnet_id in vnet_to_peering_map[vnet_id]["peerings"]:
        if is_reciprocal_peering(vnet_id, remote_vnet_id):
            explore_reciprocal_peering_group(remote_vnet_id, group)