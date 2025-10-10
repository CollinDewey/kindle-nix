.PHONY: all clean

all: kindle-nix-installer.sh

kindle-nix-installer.sh: install.sh nix-daemon.conf nix.conf
	@sed -e '/__NIX_DAEMON_CONF__/r nix-daemon.conf' \
	     -e '/__NIX_CONF__/r nix.conf' \
		 -e '/__NIX_UNINSTALL__/r uninstall.sh' \
	     -e '/__NIX_DAEMON_CONF__/d' \
	     -e '/__NIX_CONF__/d' \
	     -e '/__NIX_UNINSTALL__/d' \
	     install.sh > kindle-nix-installer.sh
	@chmod +x kindle-nix-installer.sh

clean:
	rm -f kindle-nix-installer.sh
