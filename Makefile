MAKEFLAGS += --silent

NAME = $(shell cat NAME)
VERSION = $(shell cat VERSION)
URL = https://github.com/radxa-pkg/dthelper
DESCRIPTION = Device tree helper from LibreELEC

all:
	cd ./src && \
	git config --get user.name || git config user.name "Radxa" && \
	git config --get user.email || git config user.email "dev@radxa.com" && \
	git am ../*.patch && \
	cd ..

	rm -rf ./.deb-pkg/
	mkdir -p ./.deb-pkg/usr/bin
	cp ./src/packages/sysutils/busybox/scripts/dthelper ./.deb-pkg/usr/bin
	ln -sf dthelper ./.deb-pkg/usr/bin/dtfile
	ln -sf dthelper ./.deb-pkg/usr/bin/dtflag
	ln -sf dthelper ./.deb-pkg/usr/bin/dtname
	ln -sf dthelper ./.deb-pkg/usr/bin/dtsoc

	fpm -s dir -t deb -n $(NAME) -v $(VERSION) \
		-a all \
		--deb-priority optional --category admin \
		--deb-field "Multi-Arch: foreign" \
		--deb-field "Replaces: $(NAME)" \
		--deb-field "Conflicts: $(NAME)" \
		--deb-field "Provides: $(NAME)" \
		--url $(URL) \
		--description "$(DESCRIPTION)" \
		--license "GPL-2+" \
		-m "Radxa <dev@radxa.com>" \
		--vendor "Radxa" \
		--force \
		./.deb-pkg/=/

	rm -rf ./.deb-pkg/