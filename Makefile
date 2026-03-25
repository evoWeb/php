MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.SILENT:

# use the rest as arguments for "run"
_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(_ARGS):;@:)

MKFILE_PATH := $(realpath $(firstword $(MAKEFILE_LIST)))
CI_PROJECT_DIR := $(patsubst %/,%,$(dir $(MKFILE_PATH)))


define web-build
	echo "Build \"evoweb/php:$${VERSION}-$${TYPE}\""
	docker buildx build \
		--load \
		--no-cache \
		--compress \
		--progress=plain \
		--build-arg TYPE=$${TYPE} \
		--build-arg VERSION=$${VERSION} \
		--tag evoweb/php:$${VERSION}-$${TYPE} \
		-f web/$${VERSION}/Dockerfile \
		.
endef


define web-test
	docker run --rm evoweb/php:$${VERSION}-$${TYPE} php -v
endef


# $(1)=version $(2)=type
define web-target
.PHONY: test-$(1)-$(2)
test-$(1)-$(2): ##@ Run test build of PHP $(1)[7.4, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5] $(2)[fpm, debug]
test-$(1)-$(2): VERSION=$(1)
test-$(1)-$(2): TYPE=$(2)
test-$(1)-$(2):
	$(web-build)
	$(web-test)
endef


define non-web-build
	echo "Build \"evoweb/php:$${TYPE}\""
	docker buildx build \
		--load \
		--no-cache \
		--compress \
		--progress=plain \
		--tag evoweb/php:$${TYPE} \
		-f $${TYPE}/Dockerfile \
		.
endef


define non-web-test
	docker run --rm evoweb/php:$${TYPE} php -v
endef


# $(1)=version $(2)=type
define non-web-target
.PHONY: test-$(1)
test-$(1): ##@ Run test build of PHP $(1)[crontab, composer, composer-node]
test-$(1): TYPE=$(1)
test-$(1):
	$(non-web-build)
	$(non-web-test)
endef


##@
##@ Commands to call test builds with different arguments
##@

$(eval $(call web-target,7.4,debug))
$(eval $(call web-target,7.4,fpm))
$(eval $(call web-target,8.0,debug))
$(eval $(call web-target,8.0,fpm))
$(eval $(call web-target,8.1,debug))
$(eval $(call web-target,8.1,fpm))
$(eval $(call web-target,8.2,debug))
$(eval $(call web-target,8.2,fpm))
$(eval $(call web-target,8.3,debug))
$(eval $(call web-target,8.3,fpm))
$(eval $(call web-target,8.4,debug))
$(eval $(call web-target,8.4,fpm))
$(eval $(call web-target,8.5,debug))
$(eval $(call web-target,8.5,fpm))

$(eval $(call non-web-target,crontab))
$(eval $(call non-web-target,composer))
$(eval $(call non-web-target,composer-node))


.PHONY: all-tests
all-tests: ##@ Run all tests
all-tests: test-7.4-debug
all-tests: test-7.4-fpm
all-tests: test-8.0-debug
all-tests: test-8.0-fpm
all-tests: test-8.1-debug
all-tests: test-8.1-fpm
all-tests: test-8.2-debug
all-tests: test-8.2-fpm
all-tests: test-8.3-debug
all-tests: test-8.3-fpm
all-tests: test-8.4-debug
all-tests: test-8.4-fpm
all-tests: test-8.5-debug
all-tests: test-8.5-fpm
all-tests: test-crontab
all-tests: test-composer
all-tests: test-composer-node

help:
	@printf "\nUsage: make \033[32m<command>\033[0m\n"
	grep -F -h "##@" $(MAKEFILE_LIST) | \
	grep -F -v grep -F | \
	grep -F -v awk -F | \
	awk 'BEGIN {FS = ":*[[:space:]]*##@[[:space:]]*"}; \
	{ \
		if ($$2 == "") \
			printf ""; \
		else if ($$0 ~ /^#/) \
			printf "\n%s\n\n", $$2; \
		else if ($$1 == "") \
			printf "     %-30s%s\n", "", $$2; \
		else \
			printf "    \033[32m%-30s\033[0m %s\n", $$1, $$2; \
	}'
.DEFAULT_GOAL := help
