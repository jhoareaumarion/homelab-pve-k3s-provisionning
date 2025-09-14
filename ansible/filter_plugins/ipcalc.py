# filter_plugins/ipcalc.py

from ansible.errors import AnsibleFilterError

def network_address(ip_cidr, append_subnet=False):
    try:
        import ipaddress
        ip_network = ipaddress.ip_network(ip_cidr, strict=False)
        network_addr = str(ip_network.network_address)
        if append_subnet:
            network_addr += f"/{ip_network.prefixlen}"
        return network_addr
    except Exception as e:
        raise AnsibleFilterError('Failed to calculate network address: {}'.format(e))

class FilterModule(object):
    def filters(self):
        return {
            'network_address': network_address,
        }
