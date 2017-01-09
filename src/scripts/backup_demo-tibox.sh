#!/bin/bash
#
#-----------------------------------------------------------------------
#
# Script to backup all needed data upon USB hard disk insertion
# It is called thru UDEV with :
#  - the device name (sda1, ...) given as the first parameter
#
#-----------------------------------------------------------------------
# Voir sur http://bernaerts.dyndns.org/linux/75-debian/54-debian-udev-backup

# Log beggining of backup
/usr/bin/logger Sauvegarde - démarrage le `date`
# if needed, create the mount directory
if [ ! -d /mnt/backup ] ; then mkdir /mnt/backup ; fi

# On rend la partition du disque USB visible
/bin/mount -t auto /dev/$1 /mnt/backup

# Sauvegarde du serveur lui-même
/usr/bin/logger Sauvegarde - Configuration /etc/
/usr/bin/rsync -rtv --modify-window=2 /etc/ /mnt/backup/etc

# On exclue le contenu des bibliothèques
/usr/bin/logger Sauvegarde - Configuration Seafile
/usr/bin/rsync -rtv --exclude 'seafile-data/storage' --modify-window=2 /srv/seafile.lesfeesrosses.org/ /mnt/backup/srv_seafile.lesfeesrosses.org/

# On sauvegarde le contenu des bibliothèques
/usr/bin/logger Sauvegarde - Contenu Seafile
if [ ! -d /mnt/seafile-fuse ] ; then mkdir /mnt/seafile-fuse ; fi
# Demonte le dossier si file au cas ou le dernier backup l'ait laisse dans un drole d'etat
fusermount -zu /mnt/seafile-fuse
/srv/seafile.lesfeesrosses.org/seafile-server-latest/seaf-fuse.sh start /mnt/seafile-fuse
/usr/bin/rsync -rtv --exclude 'seafile-data/storage' --modify-window=2 /mnt/seafile-fuse/ /mnt/backup/contenus_seafile/

# You can add here some other backups ...
#/usr/bin/logger Backup - other files
#/usr/bin/rsync -rtv --del --modify-window=2 /path/to/your/files/other /mnt/backup

# force sync of files to disk before unmounting
/bin/sync

# unmount the backup disk
/srv/seafile.lesfeesrosses.org/seafile-server-latest/seaf-fuse.sh stop
/bin/umount /mnt/backup

# Log end of backup
/usr/bin/logger Sauvegarde - terminée le `date`
