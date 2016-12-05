#!/bin/bash

set -e

virsh --connect=qemu:///system reset gpdb-seg1-vm
virsh --connect=qemu:///system reset gpdb-seg2-vm
virsh --connect=qemu:///system reset gpdb-test-master-vm

