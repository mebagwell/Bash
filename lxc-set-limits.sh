#!/bin/bash
## Backup all Instances
for i in $(lxc list -c n --format csv)
do
  lxc config set $i limits.cpu 8
  lxc config set $i limits.memory 1GB
  lxc config set $i limits.cpu.allowance 20ms/10ms
done
