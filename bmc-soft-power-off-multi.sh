#!/bin/bash
# Power off multiple servers

for i in $(seq $1 $2)
do
  echo "loadgen$i"
  /tools/bin/bmc-soft-power-off loadgen$i-bmc smc
done
