# Copyright (C) 2017  Tetras-libre <admin@tetras-libre.fr>
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

NAME=tetras-back
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SCRIPTS_DIR=$(PREFIX)/lib/
RULES_DIR=/etc/udev/rules.d
RULE_NAME=50-$(NAME).rules
WEB_PREFIX=/var/www/
APACHE_CONF_DIR=/etc/apache2/conf-available
SERVICE_DIR=/etc/systemd/system

all: install

install: start_daemon

start_daemon: daemon
	systemctl start $(NAME).service

daemon: rule web
	@echo "Installing main daemon"
	mkdir $(BINDIR)
	cp src/$(NAME) $(BINDIR)/
	cp src/scripts/* $(SCRIPTS_DIR)/
	@echo "Installing configuration file"
	mkdir /etc/$(NAME)
	cp src/configuration.pl	/etc/$(NAME)
	@echo "Creating systemd service"
	cp src/service/$(NAME).service $(SERVICE_DIR)/
	@echo "Reloading systemd"
	systemctl daemon-reload

rule:
	@echo "Installing udev rule"
	cp src/rules/$(RULE_NAME) $(RULES_DIR)
	@echo "Restarting udev"
	systemctl restart udev

web: clean-web web-conf-apache
	@echo "Copying web files"
	cp -r src/www/* $(WEB_PREFIX)/$(NAME)

web-conf-apache:
	@echo "Copying apache configuration file"
	cp src/apache/$(NAME).conf $(APACHE_CONF_DIR)/
	@echo "Enabling apache configuration"
	a2enconf $(NAME)

clean-web:
	@echo "Removing old web installation"
	rm -rf $(WEB_PREFIX)/$(NAME)

uninstall:
	rm -rf $(WEB_PREFIX)/$(NAME) $(BINDIR)/$(NAME) $(RULES_DIR)/$(RULE_NAME)
