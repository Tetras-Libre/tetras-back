#!/bin/bash
#

# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Beniamine, David <David.Beniamine@tetras-libre.fr>
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


# If $1 is not 0, exit with message $2
test_and_fail(){
    [ $1 -ne 0 ] && echo "Echec de la sauvegarde : '$2'" && exit $1
}

# Retourne le premier element
permier(){
    echo $1
}

# Supprime la sauvegarde la plus ancienne
supprimer_anciennes_sauvegardes(){
    dir=`premier \`/bin/ls $dest/..\``
    [ -z "$dir" ] && return 1
    do_log "Plus de place suppression de la sauvegarde la plus ancienne: $dir"
    rm -rf $dest/../$dir
}

do_log(){
    echo "Sauvegarde NoCloud - $@"
}

sauvegarde_mysql(){
    do_log "Sauvegarde mysql"
    mysqldump --single-transaction --flush-logs --all-databases \
        | gzip > /root/db.sql.gz
}

sauvegarde_serveur(){
    do_log "Creation de l'archive configuration serveur"
    tar cvzf $dest/serveur.tgz $srv_directories
}

sauvegarde_donnees(){
    cp -r /home $dest/Donnees
}

# $1 should be an unmounted device like /dev/sdb1
test ! -z "$1"
test_and_fail $? "Pas de disque donnée, abandon"

dev=$1
dest=/mnt/backup
date=`date +%Y-%m-%d_%H-%M-%S`
srv_directories="/root /etc /srv /var/www"
data_directories="/home"

do_log "démarrage le `date`"

[ ! -d $dest ] && mkdir $dest

/bin/mount -t auto $dev $dest
test_and_fail $? "Impossible de monter le disque destination, abandon"

dest=$dest/$date
mkdir $dest

sauvegarde_mysql
test_and_fail $? "Impossible de sauvegarde la base de donnée mysql"
do_log "Sauvegarde mysql reussie"

for action in sauvegarde_serveur sauvegarde_donnees
do
    $action
    ret=$?
    while [ $ret -ne 0 ]
    do
        supprimer_anciennes_sauvegardes
        test_and_fail $? "Plus d'espace sur le disque et pas d'ancienne sauvegarde a supprimer"
        $action
        ret=$?
    done
    nom=${action/_/ }
    do_log "$nom reussie"
done
do_log "Sauvegarde terminee le `date`"
