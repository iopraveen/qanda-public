required_bins := composer npm node php npm-shrinkwrap

exists_package := $(shell command -v dot 2> /dev/null)



.PHONY: all
all:
	cd backend && $(MAKE)
	cd frontend && $(MAKE)

.PHONY: dev
dev:
	cd backend && $(MAKE) dev
	cd frontend && $(MAKE) dev

.PHONY: watch
watch:
	rpm --query inotify-tools || $(MAKE) inotify-tools
	while true; do \
		inotifywait -qr -e modify -e create -e delete -e move .; \
		$(MAKE) dev; \
	done

########################################################################################
# install os packages

.PHONY: inotify-tools
inotify-tools:
	yum-config-manager --enable epel
	yum update
	$(call install_os_pkg, $@)
	yum-config-manager --disable epel
	yum update

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

########################################################################################
#

