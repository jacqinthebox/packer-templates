#!/bin/bash
./packer build --force ./templates/parallels_windows_server_2016_1_base.json
./packer build --force ./templates/parallels_windows_server_2016_2_updates.json
./packer build --force ./templates/parallels_windows_server_2016_3_package.json
