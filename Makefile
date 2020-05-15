SHELL := /bin/bash
JSON_PP := json_pp -json_opt pretty,relaxed,utf8
GENERATED_JSONS := _site/api/concepts/*.json _site/api/concepts/*.jsonld

all: _site | postprocess

clean:
	rm -rf _site

distclean: clean
	rm -rf _data/info.yaml

data: _data/info.yaml _data/metadata.yaml

_site: data | bundle
	bundle exec jekyll build

postprocess:
	echo "Postprocessing JSONs..."; \
	for f in ${GENERATED_JSONS}; do \
		mv $${f} .tmp.json; \
		${JSON_PP} < .tmp.json > $${f} && rm .tmp.json || mv .tmp.json $${f}; \
	done

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

.PHONY: data bundle all open serve distclean clean update-init update-modules postprocess
