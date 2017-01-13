# Tetras-back

Tetras-back est un logiciel libe, conçu pour sauvegarder des serveurs d'auto
hebergements sur des disques dur externes.

## Prérequis

Tetras-Back a été testé sur debian Jessie et Testing, pour l'utiliser, vous
avez besoin de:

+ Systemd
+ Udev
+ Sendmail fonctionnel
+ Perl


## Installation

En tant que root, executez `make dependencies && make` depuis ce repertoir

## Utilisation

## Comment ça marche

Un service systemd tourne en permanance. Lorsqu'un disque est branché, une
règle udev notify le service du nouveau disque. Si le disque est déjà connu une
sauvegarde est déclenchée.
Les scripts de sauvegardes sont reponsable de la gestion de l'espace disque.
Des clients peuvent suivre les modifications et déclencher des sauvegardes /
ajouter ou supprimer des disques en dialoguant via la ligne de commande et des
fichiers json.
L'administrateur est notifié des sauvegardes et des echecs par email.

## Interface Web

L'interface web n'est pas encore implémentée

## Scripts de sauvegarde fournis

### backup_nocloud.sh

Ce script est celui par default, il permet de sauvegarder les solutions NoCloud
de Demo-TIC et Tetras Libre. Il crée un dossier
`YYYY-MM-DD_HH-MM-SS_Sauvegarde_Hostname` par sauvegarde sur le disque externe.
Ce dossier contient un dossier "Donnees" correspondant au `/home` du serveur et
une archiver `serveur.tar.gz` contenant les dossier `/etc`, `/srv`, `/var/www`,
`/root` du serveur. Dans ce dernier dossier on peut trouver un dump de la base
de donnée mysql.  Si il n'y a pas assez de place sur le disque externe, le
script supprimera les anciennes sauvegardes.

### backup_demo-tibox.sh

Ce script sert à sauvegarder les Demo-Tibox de Demo-TIC, il sauvegarde les
dossier `/etc` et `/home` par Rsync.

## CLI

### Gérer les disques

Les sauvegarde ne sont faite que sur les disques mémorisés, pour sauver un disque:

    tetras-back --save UUID=name

Pour oublier un disque

    tetras-back --forget UUID

Le uuid peut être trouver grace à la commande `blkid`

### Configuration

Le fichier `/etc/tetras-back/configuration.pl` permet de gerer à la main les
disques connus et d'activer ou désactiver des scripts. Tous les scripts doivent
être dans `/usr/local/lib/tetras-back` et doivent être executable. Avant de
modifier ce fichier il faut stopper tetras-back `systemctl stop tetras-back` et
le réactiver après `systemctl start tetras-back`.

### Avancé

Les clients sont notifiés de toutes les modifications de disque via une fifo
dans laquelle on envoi un fichier json.
La page web est implémentée comme un client.

#### Gérer les clients

Ajouter un nouveau client:

    mkfifo /path/to/my.fifo
    tetras-back --register  /path/to/my.fifo

A partir de là, le client sera notifié à chaque modification des disques.

#### Connecter un disque

Les connexions disques sont gérrées par udev, mais on peux vouloir pour tester
ou pour forcer une sauvegarde simuler une connexion ou deconnection.

    tetras-back --plug <device>

ou

    tetras-back --unplug <device>

La device etant quelque chose du genre `/dev/sdb1`

## Projet

### Todo

+ [ ] Web interface
+ [x] Sendmail after backup or on fail
+ [x] Daemon
+ [x] Udev rules
+ [x] Disc Selection
+ [x] Configuration file

### Hierarchie des dossiers

    /src/tetras-back                    Daemon script (perl)
    /src/configuration.pl               Configuration (perl)
    /src/rules/50-tetras-back.rules     Rules for USB drives
    /src/scripts/*                      Backup scripts
    /src/service                        Systemd service



## Licence

This program is distributed under GPLV3 Licence, see `Licence.txt`
