#!/usr/bin/env python
"""
This script retrieves the external domain name from the EDA EngineConfig
and resolves it to an IP address.
"""

import socket
import subprocess
from typing import Optional


def get_eda_ext_domain() -> str:
    cmd = [
        "kubectl",
        "-n",
        "eda-system",
        "get",
        "engineconfigs/engine-config",
        "-o",
        "jsonpath={.spec.cluster.external.domainName}",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()


def is_ip_address(input: str) -> bool:
    try:
        socket.inet_aton(input)
        return True
    except socket.error:
        return False


def resolve_domain(domain: str) -> Optional[str]:
    try:
        if is_ip_address(domain):
            return domain
        return socket.gethostbyname(domain)
    except socket.gaierror:
        return None


def main():
    ext_domain = get_eda_ext_domain()
    if is_ip_address(ext_domain):
        print(ext_domain)
    else:
        resolved_ip = resolve_domain(ext_domain)
        print(resolved_ip)


if __name__ == "__main__":
    main()
