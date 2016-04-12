INSTALL_PATH ?= $$HOME/.notepad.vim
INSTALL_BIN_PATH ?= $$HOME/bin

update_plugins := cd .. && sh notepad.vim/update.sh
ask_for_updating_plugins := function ask() { echo -n "$$1 [Y/N]> "; read -r; test "$${REPLY\#[yY]}" != "$${REPLY}" || return 1; }; ask "Install additional plugins?"

.PHONY: all
all: usage

.PHONY: usage
usage:
	@echo "Type \"make install\" to install notepad.vim into $(INSTALL_PATH)"

update: dependencies update.sh
	@ $(update_plugins)

install: installer_bin.sh update.sh installer_first_help
	mkdir -p "$(INSTALL_PATH)"/bundle
	cd "$(INSTALL_PATH)"/bundle && ln -s -f "$(CURDIR)" .
	@ sh installer_bin.sh "$(INSTALL_PATH)" "$(INSTALL_BIN_PATH)" bin
	@ ( $(ask_for_updating_plugins) && cd "$(INSTALL_PATH)"/bundle/notepad.vim && $(update_plugins) ) || true
	@ echo
	@ cat installer_first_help

