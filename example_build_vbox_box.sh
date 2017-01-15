#!/bin/bash
./packer build ./virtualbox_windows_server_2016_1_base.json
./packer build ./virtualbox_windows_server_2016_2_updates.json
./packer build ./virtualbox_windows_server_2016_3_package_only.json
./packer build ./virtualbox_windows_server_2016_4_vbox_export.json
#./packer build ./virtualbox_windows_server_2016_4_hyperv_export.json
