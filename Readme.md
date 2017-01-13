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

## Web

L'interface web n'est pas encore implémentée

### Hierarchie des dossiers

    /src/tetras-back                    Daemon script (perl)
    /src/configuration.pl               Configuration (perl)
    /src/rules/50-tetras-back.rules     Rules for USB drives
    /src/scripts/*                      Backup scripts
    /src/service                        Systemd service

## Todo

+ [x] Sendmail after backup or on fail
+ [x] Daemon
+ [x] Udev rules
+ [ ] Apache2 rule
+ [ ] Web interface
+ [x] Disc Selection
+ [x] Configuration file

## Licence

This program is distributed under GPLV3 Licence, see `Licence.txt`
