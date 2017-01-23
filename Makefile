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
WEB_CLIENT=$(WEB_PREFIX)/$(NAME)/tl-client
APACHE_CONF_DIR=/etc/apache2/conf-available
SERVICE_DIR=/etc/systemd/system
DEPENDENCIES=encfs php5-json cpanminus
HTUSER=tetras-back

all: install

install: start_daemon web
	systemctl enable $(NAME).service

dependencies:
	@echo "Installing dependencies"
	apt-get -q -y install $(DEPENDENCIES)
	for dep in `grep "^use.*::.*;" src/tetras-back  | sed 's/^use\s*\(\S*\)[ ;].*/\1/'`; \
		do cpanm $$dep; done

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
	chown root:root /etc/$(NAME)/configuration.pl
	chmod 600 /etc/$(NAME)/configuration.pl
	@echo "Enabling logrotate"
	cp src/logrotate/* /etc/logrotate.d/
	@echo "Creating systemd service"
	cp src/service/$(NAME).service $(SERVICE_DIR)/
	mkdir -p /var/log/tetras-back
	touch /var/log/tetras-back/main.log
	chown -R root:root /var/log/tetras-back
	chmod -R 644 /var/log/tetras-back/*
	chmod  755 /var/log/tetras-back/
	sed -i -e "s@\(ExecStart=\)[^ ]*@\1$(BINDIR)/$(NAME)@"  $(SERVICE_DIR)/$(NAME).service
	@echo "Reloading systemd"
	systemctl daemon-reload

rule:
	@echo "Installing udev rule"
	cp src/rules/$(RULE_NAME) $(RULES_DIR)
	@echo "Restarting udev"
	systemctl restart udev

web:
	@echo "Copying web files"
	mkdir -p $(WEB_PREFIX)/$(NAME)
	cp -r src/www/* $(WEB_PREFIX)/$(NAME)/
	chown -R www-data:www-data $(WEB_PREFIX)/$(NAME)
	touch $(WEB_CLIENT)
	tetras-back --register $(WEB_CLIENT)

htpass:
	if [ ! -z '$(HTPASS)' ]; then \
		htpasswd -b -c $(WEB_PREFIX)/$(NAME)/.htpasswd $(HTUSER) '$(HTPASS)';\
		else \
		htpasswd -c $(WEB_PREFIX)/$(NAME)/.htpasswd $(HTUSER); \
		fi
	mv $(WEB_PREFIX)/$(NAME)/htaccess  $(WEB_PREFIX)/$(NAME)/.htaccess
	chown -R www-data:www-data $(WEB_PREFIX)/$(NAME)

clean-web:
	@echo "Removing old web installation"
	if [ -e $(WEB_CLIENT) ]; then tetras-back --unregister $(WEB_CLIENT); \
		cat $(WEB_CLIENT); rm $(WEB_CLIENT); fi
	rm -rf $(WEB_PREFIX)/$(NAME)

uninstall:
	systemctl disable tetras-back
	rm -rf $(WEB_PREFIX)/$(NAME) $(BINDIR)/$(NAME) $(RULES_DIR)/$(RULE_NAME) $(SERVICE_DIR)/$(NAME).service
	systemctl daemon-reload
	systemctl restart udev

test:
	bash src/tests/test.sh
