########################################################################################
# config

BIN					?= bin

COMPOSER        	?= $(BIN)/composer
HTTP_SERVER			?= httpd

# a list of directories containing web server configurations
HTTP_CONF			?= /etc/httpd/conf/httpd.conf
HTTP_EXTRA_CONF_DIR	?= /etc/httpd/conf.d
HTTP_CONF_EXT		?= conf
HTTP_PID_FILE		?= /var/run/httpd/httpd.pid
HTTP_OS_PKGS		?= pcre-devel httpd24-devel


COMPOSER_DEV_BUILDS 	?= composer-dev.builds
COMPOSER_PROD_BUILDS 	?= composer-prod.builds

os_packages				?= $(shell jq -r '.extra.os_packages[]' composer.json)
os_packages_dev			?= $(shell jq -r '.extra.os_packages_dev[]' composer.json)

commands				?= $(shell jq '.extra | .commands[]' composer.json)
commands_dev			?= $(shell jq '.extra | .commands[]' composer.json)

########################################################################################

REMOVE = rm -rf

macro_find_files = $(shell find $(1) -type f -name "*.$(2)")
macro_find_dirs = $(shell find $(1) -type d)

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

app_php_dirs 		= $(shell jq -r '.autoload.classmap[]' composer.json)
app_php_files 		= $(foreach d,$(app_php_dirs),$(call macro_find_files,$(d),"php"))


server_confs = $(foreach d,$(HTTP_EXTRA_CONF_DIR),$(call macro_find_files,$(d),$(HTTP_CONF_EXT)))

composer_flags := --no-suggest
vendor_php_files = $(foreach d,vendor,$(call macro_find_files,$(d),"php"))

########################################################################################

.PHONY: prod
prod: install_web_server install_os install_composer commands $(COMPOSER_PROD_BUILDS) end 

.PHONY: dev
dev: prod install_os_dev $(COMPOSER_DEV_BUILDS) end 

.PHONY: end
end: reload_server vendor/autoload.php 

########################################################################################
# OS packages

.PHONY: install_os
install_os: installed_pkgs.builds

installed_pkgs.builds: composer.json
ifneq ($(os_packages),)
	$(call install_os_pkgs, $(os_packages))
	touch $@
endif

.PHONY: install_os_dev
install_os_dev: install_os installed_pkgs_dev.builds

installed_pkgs_dev.builds: composer.json
ifneq ($(os_packages_dev),)
	$(call install_os_pkgs, $(os_packages_dev))
	touch $@
endif

.PHONY: install_os_dev
commands: commands.builds

commands.builds: composer.json
ifneq ($(commands),)
	$(call install_commands, $(commands))
	touch $@
endif

.PHONY: commands_dev
commands_dev: commands commands_dev.builds

commands_dev.builds: composer.json
ifneq ($(commands_dev),)
	$(call install_commands, $(commands_dev))
	touch $@
endif


########################################################################################
# Application files

# this is triggered when:
#
# 1. one or more of the
# app_php_files are updated
#
# 2. vendor/autoload.php
# doesn't exist yet

vendor/autoload.php: $(app_php_files)
	$(COMPOSER) dump-autoload

########################################################################################
# Composer

.PHONY: install_composer
install_composer : $(COMPOSER)

$(COMPOSER): | $(BIN)
	sudo curl -sS https://getcomposer.org/installer | sudo php
	mv composer.phar $(COMPOSER) 
	$(COMPOSER) self-update

$(BIN):
	test -d $(BIN) || mkdir $(BIN)
	

# this is triggered when:
#
# 1. composer.json is updated
# 2. file $(COMPOSER_DEV_BUILDS)
# doesn't exist yet
$(COMPOSER_DEV_BUILDS): composer.json
	$(shell if ! test -f $@; then $(REMOVE) $(COMPOSER_PROD_BUILDS); fi)
	$(call composer_install,$(composer_flags))
	$(call increment_build_version, $@)

# this is triggered when:
#
# 1. composer.json is updated
# 2. file $(COMPOSER_PROD_BUILDS)
# doesn't exist yet
$(COMPOSER_PROD_BUILDS): composer.json
	$(shell if ! test -f $@; then $(REMOVE) $(COMPOSER_DEV_BUILDS); fi)
	$(eval composer_flags += --no-dev)
	$(call composer_install,$(composer_flags))
	$(call increment_build_version, $@)

define composer_install
	-$(REMOVE) vendor composer.lock
	$(COMPOSER) install $(1)
endef

########################################################################################
# Web Server


.PHONY: install_web_server
install_web_server: $(HTTP_CONF)

$(HTTP_CONF):
	$(call install_os_pkgs, $(HTTP_OS_PKGS))
	chkconfig $(HTTP_SERVER) on
	$(MAKE) server_start

.PHONY: reload_server
reload_server: $(HTTP_PID_FILE)


# this is triggered when:
#
# 1. HTTP_PID_FILE doesn't exist
# (httpd isn't currently running)
#
# 2. one or more of the conf's are updated

$(HTTP_PID_FILE): $(server_confs)
	$(MAKE) server_stop
	service $(HTTP_SERVER) start
	touch $@


.PHONY: server_start
server_start:
	service $(HTTP_SERVER) start

.PHONY: server_stop
server_stop:
	service $(HTTP_SERVER) stop
	-killall $(HTTP_SERVER)

########################################################################################
# Common Functions

define increment_build_version
	$(shell if ! test -f $(1); then echo 0 > $(1); fi)
	$(shell echo $$(($$(cat $(1)) + 1)) > $(1))
endef

define install_os_pkgs
	yum install -y $(1)
endef

define install_os_pkg
	yum install -y $(1)
endef

define install_commands
	for command in $(1); do \
		$$command ; \
	done
endef


########################################################################################
#
