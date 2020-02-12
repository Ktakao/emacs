SYMLINK_PREFIX := ~/.emacs.d
DIR_TARGET := backups conf elisp etc howm info public_repos undohist
DIR_PATH := $(addprefix .emacs.d/,$(DIR_TARGET))

.PHONY: all install uninstall

all:
	@echo -e "make targets: install uninstall"
install:
	mkdir -p $(DIR_PATH)
	ln -s $(CURDIR)/.emacs.d $(SYMLINK_PREFIX)
uninstall:
	unlink $(SYMLINK_PREFIX)
