# CSD_SRC  := $(wildcard csd/*.xml)
# CSD_HTML := $(patsubst %.xml,%.html,$(CSD_SRC))
# CSD_PDF  := $(patsubst %.xml,%.pdf,$(CSD_SRC))
# CSD_DOC  := $(patsubst %.xml,%.doc,$(CSD_SRC))
# CSD_RXL  := $(patsubst %.xml,%.rxl,$(CSD_SRC))
# CSD_YAML := $(patsubst %.xml,%.yaml,$(CSD_SRC))
# RELATON_CSD_RXL := $(addprefix relaton-csd/, $(notdir $(CSD_SRC)))

# NAME_ORG := "CalConnect : The Calendaring and Scheduling Consortium"
# CSD_REGISTRY_NAME := "CalConnect Document Registry: Standards"
# ADMIN_REGISTRY_NAME := "CalConnect Document Registry: Administrative Documents"
#
# INDEX_CSS := templates/index-style.css
# INDEX_OUTPUT := index.xml index.html admin.rxl admin.html external.rxl external.html

all: _site

clean:
	rm -rf _site _concepts

distclean: clean
	rm -rf _data/info.yaml

data: _data/info.yaml _concepts

_site: data | bundle
	bundle exec jekyll build

bundle:
	bundle

_data/info.yaml: geolexica-database/tc211-termbase.meta.yaml
	cp -f $< $@

# Make collection YAML files into adoc files
_concepts:
	mkdir -p $@
	for filename in geolexica-database/concepts/*.yaml; do \
	    [ -e "$$filename" ] || continue; \
			newpath=$${filename//$<\/concept-/$@\/}; \
	    cp $$filename $${newpath//yaml/adoc}; \
			echo "---" >> $${newpath//yaml/adoc}; \
	done

# index.xml: csd.rxl external.rxl admin.rxl
# 	cp -a external/*.rxl csd/; \
# 	bundle exec relaton concatenate \
# 	  -t $(CSD_REGISTRY_NAME) \
# 		-g $(NAME_ORG) \
# 	  csd/ $@

serve:
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git pull origin master

.PHONY: data bundle all open serve distclean clean update-init update-modules
