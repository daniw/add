#!/bin/bash
mkdir ilias ilias_copy &> /dev/null
./mount.sh
cp -r -u -v ilias ilias_copy
./umount.sh
