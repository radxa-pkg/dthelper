MAKEFLAGS += --silent

NAME = $(shell cat NAME)
VERSION = $(shell cat VERSION)
URL = https://github.com/radxa-pkg/libreelec-alsa-utils
DESCRIPTION = ALSA helper from LibreELEC

all:
	rm -rf ./.deb-pkg/
	mkdir -p ./.deb-pkg/usr/lib/udev/rules.d/
	cp ./src/packages/audio/alsa-utils/scripts/soundconfig ./.deb-pkg/usr/lib/udev
	# truly magic happening here. script won't work without piping
	sed -i -e 's+progress "Setting up sound card"+echo "Setting up sound card" | cat+g' ./.deb-pkg/usr/lib/udev/soundconfig
	cp ./src/packages/audio/alsa-utils/udev.d/90-alsa-restore.rules ./.deb-pkg/usr/lib/udev/rules.d
	mkdir -p ./.deb-pkg/usr/bin
	cp ./src/packages/sysutils/busybox/scripts/dthelper ./.deb-pkg/usr/bin
	sed -i -e "s+cat /proc/device-tree/compatible | cut -f1,2 -d','+tr '\\\0' '\\\n' < /proc/device-tree/compatible+g" ./.deb-pkg/usr/bin/dthelper
	ln -sf dthelper ./.deb-pkg/usr/bin/dtfile
	ln -sf dthelper ./.deb-pkg/usr/bin/dtflag
	ln -sf dthelper ./.deb-pkg/usr/bin/dtname
	ln -sf dthelper ./.deb-pkg/usr/bin/dtsoc
	fpm -s dir -t deb -n $(NAME) -v $(VERSION) \
		-p $(NAME)_$(VERSION)_all.deb \
		--deb-priority optional --category admin \
		--force \
		--deb-field "Multi-Arch: foreign" \
		--deb-field "Replaces: $(NAME)" \
		--deb-field "Conflicts: $(NAME)" \
		--deb-field "Provides: $(NAME)" \
		--url $(URL) \
		--description "$(DESCRIPTION)" \
		--license "GPL-2+" \
		-m "Radxa <dev@radxa.com>" \
		--vendor "Radxa" \
		-a all \
		./.deb-pkg/=/
	rm -rf ./.deb-pkg/