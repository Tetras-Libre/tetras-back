# Tetras-back

Tetras-back is a free software designed to backup self hosting servers on
external hard drives.

## Requirements

To use Tetras-back, you need:

+ Systemd
+ Apache2 web server

## Install

just run `make install` from this directory

## Usage

### Manage discs

### Follow backup

### Set receiver address

### Add a backup script

## How does it works ?

### File hierarchy

    /src/tetras-back                    Daemon script (perl)
    /src/configuration.pl               Configuration (perl)
    /src/rules/50-tetras-back.rules     Rule for USB drives
    /src/scripts/*                      Backup scripts
    /src/www/tetras-back                Web page
    /src/apache2/tetras-back.conf       Apache2 configuration file
    /src/service                        Systemd service

## Todo

+ [ ] Sendmail after backup or on fail
+ [ ] Daemon
+ [ ] Udev rules
+ [ ] Apache2 rule
+ [ ] Web interface
+ [ ] Disc Selection
+ [ ] Configuration file

## Licence

This program is distributed under GPLV3 Licence, see `Licence.txt`
