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

do_clean(){
    do_log "Demontage du disque veuillez patienter avant de le retirer"
    if $encfs
    then
        fusermount -zu $encfsmount
    fi
    umount -f $dev
}

# If $1 is not 0, exit with message $2
test_and_fail(){
    if [ $1 -ne 0 ]
    then
        echo "Echec de la sauvegarde : '$2'"
        do_clean
        exit $1
    fi
}

# Retourne le premier element
premier(){
    echo $1
}

# Supprime la sauvegarde la plus ancienne
supprimer_anciennes_sauvegardes(){
    dir=`premier \`/bin/ls $dest/.. | grep $postfix \``
    [ -z "$dir" ] && return 1
    do_log "Plus de place suppression de la sauvegarde la plus ancienne: $dir"
    rm -rf $dest/../$dir
}

do_log(){
    echo "Sauvegarde NoCloud - $@"
}

sauvegarde_serveur(){
    if $mysql
    then
        do_log "Sauvegarde mysql"
        mysqldump --events --single-transaction --flush-logs --all-databases \
            | gzip > /root/db.sql.gz
        test_and_fail $? "Impossible de sauvegarde la base de donnée mysql"
    fi
    if $postgres
    then
        do_log "Sauvegarde postgresql"
         sudo -u postgres pg_dumpall > /root/pg_dump.sql
        test_and_fail $? "Impossible de sauvegarde la base de donnée postgresql"
         gzip /root/pg_dump.sql
     fi
    if $gitlab
    then
        # the backup should be in /var/opt/gitlab/backups thus in srv_directories
        do_log "Creation de la sauvegarde gitlab"
        /usr/bin/gitlab-rake $voptminus gitlab:backup:create
        backup_path=`grep "'backup_path'" /etc/gitlab/gitlab.rb  | sed 's/^.*= "\(.*\)"$/\1/'`
        if [ -d "$backup_path" ]
        then
            /bin/ls -dt $backup_path/* | tail -n +11 | xargs rm -rf
        else
            do_log "Dossier de sauvegarde gitlab non trouvé, pensez à supprimer manuellement les anciennes sauvegardes"
        fi
    fi
    do_log "Creation de l'archive configuration serveur"
    [ ! -z "$SERVICES" ] && systemctl stop $SERVICES
    tar czf$vopt $dest/serveur.tgz $srv_directories
    ret=$?
    [ ! -z "$SERVICES" ] && systemctl start $SERVICES
    if [ $ret -eq 1 ]
    then
        # only warn on tar return code 1
        do_log "Attention: des fichiers on été modifié durant la sauvegarde de l'archive serveur"
        return 0
    else
        return $ret
    fi
}

sauvegarde_donnees(){
    cp $voptminus -r /home $dest/Donnees
}

sauvegarde_seafile(){
    # On sauvegarde le contenu des bibliothèques
    echo "Sauvegarde - Contenu Seafile"
    if [ ! -d /mnt/seafile-fuse ] ; then mkdir /mnt/seafile-fuse ; fi
    # Demonte le dossier si file au cas ou le dernier backup l'ait laisse dans un drole d'etat
    fusermount -zu /mnt/seafile-fuse
    /srv/$seafile/seafile-server-latest/seaf-fuse.sh start /mnt/seafile-fuse
    /usr/bin/rsync -rtv --exclude 'seafile-data/storage' --modify-window=2 /mnt/seafile-fuse/ /$dest/contenus_seafile/
    /bin/sync
    /srv/$seafile/seafile-server-latest/seaf-fuse.sh stop
}

usage(){
    echo "Utilisation $0 [options] device"
    echo "Device doit etre un disque non monté"
    echo "Options"
    echo "  -h | --help             Affiche cette aide et quitte"
    echo "  -v | --verbose          Active le mode verbeux"
    echo "  -d | --data             Sauvegarde les donnees (/home)"
    echo "  -p | --postgresql       Sauvegarde postgresql (implique --config)"
    echo "  -m | --mysql            Sauvegarde mysql (implique --config)"
    echo "  -c | --config           Sauvegarde le serveur ($srv_directories)"
    echo "  -g | --gitlab           Sauvegarde gitlab (implique --config)"
    echo "  -u | --unifi            Sauvegarde unifi (/var/lib/unifi, implique
                                    --config)"
    echo "  -s | --seafile  host    Sauvegarde seafile host  (seafile fuse)"
    echo "  -e | --encfs    pass    Utilise des dossiers chiffrés encfs,
                                    protégés par le mot de passe donné"
    echo "  -i | --interrupt list   Interrompt les services donnés (liste
                                    séparé par des virgules) durant la création
                                    de l'archive tar."
}

dest=/mnt/backup
date=`date +%Y-%m-%d_%H-%M-%S`
postfix=_sauvegarde_`hostname`
srv_directories="/root /etc /srv /var/www /usr /lib /opt /var/opt"
data_directories="/home"
ACTIONS=""
gitlab=false
mysql=false
postgres=false
encfs=false

# Transform long options to short ones
for arg in "$@"; do
  shift
  set -- "$@" `echo $arg | sed 's/^-\(-.\).*$/\1/'`
done
optspec=":hvdcgus:mpe:i:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        h)
            usage
            exit 0
            ;;
        v)
            vopt="v"
            voptminus="-v"
            ;;
        d)
            ACTIONS+="\nsauvegarde_donnees"
            ;;
        c)
            ACTIONS+="\nsauvegarde_serveur"
            ;;
        g)
            ACTIONS+="\nsauvegarde_serveur"
            gitlab=true
            ;;
        u)
            ACTIONS+="\nsauvegarde_serveur"
            srv_directories+=" /var/lib/unifi"
            ;;
        s)
            seafile="$OPTARG"
            ACTIONS+="\nsauvegarde_seafile"
            ;;
        m)
            mysql=true
            ACTIONS+="\nsauvegarde_serveur"
            ;;
        p)
            postgres=true
            ACTIONS+="\nsauvegarde_serveur"
            ;;
        e)
            encfs=true
            ENCPASS="$OPTARG"
            ;;
        i)
            SERVICES="${OPTARG//,/ }"
            ;;
        *)
            echo "Option inconnue -$optchar"
            usage
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))
ACTIONS=`echo -e $ACTIONS | sort -u | sed /^$/d`

if [ -z "$1" ]
then
    usage
    test_and_fail 1 "Pas de disque donnée, abandon"
fi
# $1 should be an unmounted device like /dev/sdb1
dev=$1

do_log "démarrage le `date`"

[ ! -d $dest ] && mkdir $dest

/bin/mount -t auto $dev $dest
test_and_fail $? "Impossible de monter le disque destination, abandon"

if $encfs
then
    crypted="$dest/crypted"
    encfsmount="$dest/backups"
    encfscmd="/usr/bin/encfs --stdinpass $crypted $encfsmount"
    if [ ! -d $crypted ]
    then
        # First call with --encfs
        rm -rf $encfsmount
        echo -e "y\ny\np\n$ENCPASS\n" | $encfscmd
    else
        echo -e "$ENCPASS\n" | $encfscmd
    fi
    test_and_fail $? "Impossible de monter le coffre chiffré"
    unset ENCPASS
    dest=$encfsmount
fi

dest=$dest/$date$postfix
mkdir $dest

for action in $ACTIONS
do
    $action
    ret=$?
    while [ $ret -ne 0 ]
    do
        if [ `df --output=avail .  | sed 1d` -lt $((1024*1024)) ]
        then
            supprimer_anciennes_sauvegardes
            test_and_fail $? "Plus d'espace sur le disque et pas d'ancienne sauvegarde a supprimer"
            $action
            ret=$?
        else
            test_and_fail 1 "l'action '$action' a planté innopinement"
        fi
    done
    nom=${action/_/ }
    do_log "$nom reussie"
done

# force sync of files to disk before unmounting
/bin/sync
do_log "Resultats de la sauvegarde:"
du -h -d 1 $dest/
df -h $dev
do_clean
do_log "Sauvegarde terminee le `date`"
