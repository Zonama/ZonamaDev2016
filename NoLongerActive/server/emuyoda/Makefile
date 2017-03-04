DESTDIR=$(HOME)/servers/emuyoda

.PHONY: all clean install

all: yoda-config.lua
	bower install

clean:
	rm -fr html/lib yoda-config.lua

install: all


yoda-config.lua:
	sed -e "/^yodaSecret.*/s//yodaSecret = '$(dd if=/dev/urandom bs=1024 count=1 2> /dev/null|md5sum|cut -d' ' -f1)'/" -e "/^server_ip/d" yoda-config.lua.in > yoda-config.lua
