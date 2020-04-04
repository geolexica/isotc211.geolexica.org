SHELL := /bin/bash

all: _site

clean:
	rm -rf _site

distclean: clean
	rm -rf _data/info.yaml

data: _data/info.yaml _data/metadata.yaml

_site: data | bundle
	bundle exec jekyll build

bundle:
	bundle

_data/info.yaml:
	cp -f geolexica-database/tc211-termbase.meta.yaml $@

_data/metadata.yaml:
	cp -f geolexica-database/metadata.yaml $@

serve:
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git pull origin master

.PHONY: data bundle all open serve distclean clean update-init update-modules
