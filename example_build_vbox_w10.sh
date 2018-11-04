#!/bin/bash
packer build --force ./templates/virtualbox_windows_10_1_base.json
packer build --force  ./templates/virtualbox_windows_10_2_updates.json
packer build --force  ./templates/virtualbox_windows_10_3_package.json
