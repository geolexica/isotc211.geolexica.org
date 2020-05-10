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

_data/info.yaml: isotc211-glossary/tc211-termbase.meta.yaml
	cp -f $< $@

_data/metadata.yaml: isotc211-glossary/metadata.yaml
	cp -f $< $@

serve:
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git pull origin master

.PHONY: data bundle all open serve distclean clean update-init update-modules
