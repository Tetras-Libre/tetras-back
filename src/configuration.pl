#!/usr/bin/perl

%CFG = (
    'DISKS' =>{
        'CONNECTED' => {
        },
        'KNOWN' => {
        },
    },
    # Add any script as a key, it's arguments as a value
    # Last argument is always the device without any option before
    'SCRIPTS' => {
        #
        # Options
        #       --data (/home)
        #       --srv (mysql /etc /root /var/www /srv /usr /lib /opt)
        #       --gitlab => backup gitlab
        #       --unifi (/var/lib/unifi)
        #       --seafile ARG (mount seafile fuse and back it up)
        'backup_nocloud.sh' => '--data --config',
    },
    'fifo' => '/var/run/tetras-back.fifo',
