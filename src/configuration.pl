#!/usr/bin/perl

%CFG = (
    'DISKS' =>{
        'CONNECTED' => {
        },
        'KNOWN' => {
        },
    },
    'SCRIPTS' => {
        'backup_demo-tibox.sh' => 0,
        'backup_nocloud.sh' => 1,
    },
    'fifo' => '/var/run/tetras-back.fifo',
