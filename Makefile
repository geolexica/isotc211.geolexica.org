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

dist-clean:
	rm -rf concepts

_site: _concepts
	bundle exec jekyll build

concepts:
	bundle exec tc211-termbase-xlsx2yaml tc211-termbase.xlsx

# Make collection YAML files into adoc files
_concepts: concepts
	mkdir -p _concepts
	for filename in concepts/*.yaml; do \
	    [ -e "$$filename" ] || continue; \
			newpath=$${filename//concepts/_concepts}; \
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

.PHONY: bundle all open serve dist-clean clean


publish:
	mv _site published

deploy_key:
	openssl aes-256-cbc -K $(encrypted_$(ENCRYPTION_LABEL)_key) \
		-iv $(encrypted_$(ENCRYPTION_LABEL)_iv) -in $@.enc -out $@ -d && \
	chmod 600 $@

deploy: deploy_key
	export COMMIT_AUTHOR_EMAIL=$(COMMIT_AUTHOR_EMAIL); \
	./deploy.sh
