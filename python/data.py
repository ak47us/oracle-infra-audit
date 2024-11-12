from dataclasses import dataclass


@dataclass
class Peering:
    """A peering between two vnets."""
    local_vnet_address_space: list
    local_vnet_name: str
    peering_name: str
    remote_vnet_address_space: list
    remote_vnet_name: str
    # is_reciprocal: bool = False
