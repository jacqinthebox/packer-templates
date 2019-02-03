#!/bin/bash
packer build --force ./templates/parallels_windows_server_2019_1_base.json
packer build --force ./templates/parallels_windows_server_2019_2_package.json
