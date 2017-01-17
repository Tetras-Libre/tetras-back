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
        #       --verbose
        #       --config (/etc /root /var/www /srv /usr /lib /opt)
        #       --mysql (imply --config)
        #       --postgresql (imply --config)
        #       --unifi (imply --config, /var/lib/unifi)
        #       --gitlab => backup gitlab
        #       --unifi (/var/lib/unifi)
        #       --seafile ARG (mount seafile fuse and back it up)
        #       --encfs PASS (encrypt backup directory with pass
        'backup_nocloud.sh' => '--data --config --mysql',
    },
    'fifo' => '/var/run/tetras-back.fifo',
