SHELL := /bin/bash
JSON_PP := json_pp -json_opt pretty,relaxed,utf8
# _site/api/concepts/*.json files are processed with jekyll-tidy-json plugin
GENERATED_JSONS := _site/api/concepts/*.jsonld

all: _site

clean:
	rm -rf _site _source/_data/info.yaml _source/_data/metadata.yaml

data: _source/_data/info.yaml _source/_data/metadata.yaml | _source/_next

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

_source/_next: breviter/.next
	mkdir $@
	cp -rf $</. $@/

breviter/.next:
	cd breviter && yarn install && yarn build

_source/_data/info.yaml: isotc211-glossary/tc211-termbase.meta.yaml
	cp -f $< $@

_source/_data/metadata.yaml: metadata.yaml
	cp -f $< $@

metadata.yaml:
	scripts/generate_metadata.rb

serve:
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git pull origin master

.PHONY: data bundle all open serve clean update-init update-modules postprocess
