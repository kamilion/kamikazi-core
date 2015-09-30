#!/usr/bin/env bash
# This goes in /usr/local/bin/ or somewhere else in the path for best results.
xl list -l | jq '[.[] | {id: .domid, name: .config.c_info.name, type: .config.c_info.type, cpus: .config.b_info.max_vcpus, mem: .config.b_info.target_memkb,  memmax: .config.b_info.max_memkb, disks: [.config.disks[] | {device: .vdev, path: .pdev_path}], nics: [.config.nics[] | {id: .devid, mac, bridge, script}] }]' | jq -M '{kind: "vmlist", items: [.[]], totalItems: length}'
