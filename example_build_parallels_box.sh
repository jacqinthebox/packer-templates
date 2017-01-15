#!/bin/bash
./packer build ./parallels_windows_server_2016_1_base.json
./packer build ./parallels_windows_server_2016_2_updates.json
./packer build ./parallels_windows_server_2016_3_package.json
