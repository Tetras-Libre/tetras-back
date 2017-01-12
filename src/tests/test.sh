#!/bin/bash

# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Beniamine, David <David@Beniamine.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PREFIX=/usr/local/sbin
CMD=$PREFIX/tetras-back
fifo0=/tmp/client0.fifo
fifo1=/tmp/client1.fifo
prompt="press [enter] to continue"

set -e

read -p "Please follow tetras back logs: /var/log/tetras-back/*.log and config file /etc/tetras-back/configuration.pl, $prompt"

make config
make

[ ! -e $fifo0 ] && mkfifo $fifo0
[ ! -e $fifo1 ] && mkfifo $fifo1
read -p "Follow $fifo0 and $fifo1, $prompt"

$CMD --register $fifo0
$CMD --register $fifo1

read -p "Two clients should be on the configuration file, $prompt"

$CMD --leave $fifo0

read -p "Only $fifo1 should be on the configuration file, $prompt"

$CMD --register $fifo1
$CMD --leave $fifo1

read -p "No clients should be on the configuration file, $prompt"

$CMD --register $fifo0
$CMD --register $fifo1
read -p "Please enter the device of the disc used for test: " dev

read -p  "Testing on $dev, $prompt"

$CMD --plug $dev

read -p "You should see $dev as connected, plese enter it's uuid: " uuid

echo "Saving device $uuid"

$CMD --save $uuid=test0
$CMD --save $uuid=test1
read -p "The device should appear under the name test1 in the config file, $prompt"
$CMD --forget $uuid
read -p "The device should not be in the config file, $prompt"

$CMD --save $uuid=test1
read -p "Please enter the device of the second disc used for test no write will happens on this disc: " dev1

read -p  "Testing on $dev1, $prompt"

$CMD --plug $dev1

read -p "You should see $dev1 as connected, plese enter it's uuid: " uuid1

echo "Saving device $uuid1"
$CMD --save $uuid1=test2

read -p "The two devices should appear under the names test1 and test2 in the config file, $prompt"
$CMD --unplug $dev1
$CMD --forget $uuid1

read -p "Only the first device should be on the config file, trying to launch a backup, $prompt"
set +e
umount -f /dev/sdc1
set -e
$CMD --plug $dev
$CMD --unplug $dev
set +e
umount -f /dev/sdc1
set -e
read -p "Hopefully the disc should have been removed during backup, $prompt"
rm -rf /mnt/*
read -p "Replugin disc for backup, $prompt"
$CMD --plug $dev
read -p "When it is finished, please unplug the device: $CM --unplug $dev, $prompt"
