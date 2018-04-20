########################################################################################
# config

NPM						?= npm
NODE_MODULES 			?= node_modules
NODE_MODULES_BIN		?= $(NODE_MODULES)/.bin
TS_BUILD_NUMBER_FILE	?= .tsbuilds
TS_TO_JS_OUT			?= $(shell jq -r '.compilerOptions.outDir' tsconfig.json | grep -Fv node_modules | grep -Fv .d.ts)

node_version			= $(shell jq '.engines.node' package.json | grep -Fv node_modules | grep -Fv .d.ts)
node_version_nvmrc		= $(shell cat .nvmrc)

########################################################################################

ts_compiler			:= $(NODE_MODULES_BIN)/tsc

macro_find_files 	= $(shell find $(1) -type f -name "*.$(2)")
ts_includes 		= $(shell jq -r '.include[]' tsconfig.json | grep -Fv node_modules | grep -Fv .d.ts)
ts_files			= $(foreach d,$(ts_includes),$(call macro_find_files,$(d),"ts"))

mocha_args 			= --compilers js:babel-core/register --timeout 10000
REMOVE 				= rm -rf

########################################################################################

.PHONY: prod
prod: dev

.PHONY: dev
dev: update_node_version $(TS_TO_JS_OUT) package-lock.json

########################################################################################
# Node version

.PHONY: install_nvm
install_nvm: ~/.nvm/nvm.sh

~/.nvm/nvm.sh:
	-$(REMOVE) .nvmrc
	git clone git://github.com/creationix/nvm.git ~/.nvm
	. ~/.bash_profile
	echo . ~/.nvm/nvm.sh >> ~/.bashrc
	. ~/.bashrc

.PHONY: update_node_version
update_node_version: install_nvm _update_node_version

.PHONY: _update_node_version
_update_node_version: .nvmrc


.nvmrc: package.json
ifneq ($(node_version), $(node_version_nvmrc))
	echo $(node_version) > .nvmrc
endif
	$(call nvm, install $(node_version))
	$(call nvm, use $(node_version))

########################################################################################
# NPM

# this is triggered when:
# 1. package.json is updated
# 2. package-lock.json doesn't exist yet
# (eg. fresh installation)
package-lock.json: package.json
	-$(REMOVE) $(NODE_MODULES) package-lock.json
	$(NPM) install

########################################################################################
# Typescripts

# this is triggered when:
# 1. one or more of tsconfig.json $(ts_files)
# and $(ts_includes) are updated
# 2. $(TS_TO_JS_OUT) doesn't exist yet
# (eg. fresh installation)
$(TS_TO_JS_OUT): $(ts_files) $(ts_includes) tsconfig.json
	-$(REMOVE) $(TS_TO_JS_OUT)
	$(ts_compiler)
	$(call increment_build_version, $(TS_BUILD_NUMBER_FILE))

########################################################################################
# Common Functions

define increment_build_version
	$(shell if ! test -f $(1); then echo 0 > $(1); fi)
	$(shell echo $$(($$(cat $(1)) + 1)) > $(1))
endef

define nvm
	bash -l -c 'nvm $(1)'
endef

########################################################################################
#





#$(browserify) --entry=$(ts_files) --plugin=tsify -t [ babelify --extensions ".ts",".tsx",".js",".jsx" ] > $(JS_PATH)/app.js