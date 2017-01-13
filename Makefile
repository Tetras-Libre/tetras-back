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
BINDIR=$(PREFIX)/sbin
SCRIPTS_DIR=$(PREFIX)/lib/$(NAME)
RULES_DIR=/etc/udev/rules.d
RULE_NAME=50-$(NAME).rules
WEB_PREFIX=/var/www/
APACHE_CONF_DIR=/etc/apache2/conf-available
SERVICE_DIR=/etc/systemd/system
DEPENDENCIES=libmime-lite-perl libio-handle-util-perl \
			 libdata-dumper-simple-perl libcpanel-json-xs-perl \
			 liblog-dispatch-perl libgetopt-argparse-perl

all: install

install: start_daemon

dependencies:
	@echo "Installing dependencies"
	apt-get -y install $(DEPENDENCIES)

start_daemon: daemon
	systemctl restart $(NAME).service

config:
	systemctl stop tetras-back
	mkdir -p /etc/$(NAME)
	cp src/configuration.pl	/etc/$(NAME)
	echo "'scriptdir' => '$(SCRIPTS_DIR)'\n)" >> /etc/$(NAME)/configuration.pl
	perl -c /etc/$(NAME)/configuration.pl
	systemctl start tetras-back

daemon: rule
	@echo "Installing main daemon"
	mkdir -p $(BINDIR)
	perl -c src/$(NAME)
	cp src/$(NAME) $(BINDIR)/
	mkdir -p $(SCRIPTS_DIR)
	cp src/scripts/* $(SCRIPTS_DIR)/
	chmod u+x $(SCRIPTS_DIR)/*
	@echo "Installing configuration file"
	if [ -e /etc/$(NAME)/configuration.pl ]; \
		then \
		echo "Existing configuration file found, not installing the default one"; \
		echo "Run make config to overwrite it"; \
		else \
		mkdir -p /etc/$(NAME); \
		cp src/configuration.pl	/etc/$(NAME); \
		echo "'scriptdir' => '$(SCRIPTS_DIR)'\n)" >> /etc/$(NAME)/configuration.pl; \
		perl -c /etc/$(NAME)/configuration.pl; \
		fi
	@echo "Enabling logrotate"
	cp src/logrotate/* /etc/logrotate.d/
	@echo "Creating systemd service"
	cp src/service/$(NAME).service $(SERVICE_DIR)/
	sed -i -e "s@\(ExecStart=\)[^ ]*@\1$(BINDIR)/$(NAME)@"  $(SERVICE_DIR)/$(NAME).service
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
	systemctl disable tetras-back
	rm -rf $(WEB_PREFIX)/$(NAME) $(BINDIR)/$(NAME) $(RULES_DIR)/$(RULE_NAME) $(SERVICE_DIR)/$(NAME).service
	systemctl daemon-reload
	systemctl restart udev

test:
	bash src/tests/test.sh
