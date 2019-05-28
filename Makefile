# CSD_SRC  := $(wildcard csd/*.xml)
# CSD_HTML := $(patsubst %.xml,%.html,$(CSD_SRC))
# CSD_PDF  := $(patsubst %.xml,%.pdf,$(CSD_SRC))
# CSD_DOC  := $(patsubst %.xml,%.doc,$(CSD_SRC))
# CSD_RXL  := $(patsubst %.xml,%.rxl,$(CSD_SRC))
# CSD_YAML := $(patsubst %.xml,%.yaml,$(CSD_SRC))
# RELATON_CSD_RXL := $(addprefix relaton-csd/, $(notdir $(CSD_SRC)))

SHELL := /bin/bash

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
	rm -rf concepts_data tc211-termbase.yaml

_site: _concepts | bundle
	bundle exec jekyll build

bundle:
	bundle

concepts_data:
	bundle exec tc211-termbase-xlsx2yaml tc211-termbase.xlsx
	mv concepts concepts_data

# Make collection YAML files into adoc files
_concepts: concepts_data
	mkdir -p $@
	for filename in $</*.yaml; do \
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

.PHONY: bundle all open serve distclean clean

