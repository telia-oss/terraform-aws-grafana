.PHONY: default all clean test pre-build docker-build post-build build release patch-release minor-release major-release tag check-status check-release showver push run pre-push do-push post-push


default: test

# Include environment variables
include .makerc

# Image and binary can be overidden with env vars.
DOCKER_IMAGE ?= teliaoss/grafana-aws-env

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# Get the version number from the code
CODE_VERSION = $(strip $(shell cat VERSION))

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# If we're releasing to Docker Hub, and we're going to mark it with the latest tag, it should exactly match a version release
ifeq ($(MAKECMDGOALS),release)
# Use the version number as the release tag.
DOCKER_TAG = $(CODE_VERSION)

ifndef CODE_VERSION
$(error You need to create a VERSION file to build a release)
endif

# See what commit is tagged to match the version
VERSION_COMMIT = $(strip $(shell git rev-list $(CODE_VERSION) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(VERSION_COMMIT))
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
# Add the commit ref for development builds. Mark as dirty if the working directory isn't clean
DOCKER_TAG = $(CODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

SOURCES := $(shell find . -name '*.go')

# Get latest aws-env from Github Relases
CURL := $(shell command -v curl 2> /dev/null)
all:
ifndef CURL
    $(error "curl is not available please install it")
endif
AWS_ENV_GIT = "telia-oss/aws-env"
AWS_ENV_LATEST_RELEASE := $(strip $(shell curl --silent "https://api.github.com/repos/$(AWS_ENV_GIT)/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' ))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	$
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

clean: ## Clean the project
	$[info There's nothing to clean ...)

build: pre-build docker-build post-build

release: build push ## Make a release

push: pre-push do-push post-push  ## Push image to Docker hub

run: build pre-run docker-run post-run ## Run container on port configured in '.makerc'

pre-run:
	$(info Starting container  $(DOCKER_IMAGE):$(DOCKER_TAG) on $(PORT))

post-run:
	
pre-build:
    $(info Building: $(DOCKER_IMAGE):$(DOCKER_TAG) with $(CODE_VERSION):$(GIT_COMMIT))

post-build:

pre-push:
	$(info Publishing $(DOCKER_IMAGE):$(DOCKER_TAG) as $(DOCKER_IMAGE):latest ...)

post-push:

test: ## Test
	$(info Performs test)
	docker run --rm -i hadolint/hadolint < Dockerfile
	docker run -rm -

docker-run:
	docker run -d --rm -p=$(PORT):$(PORT) $(DOCKER_IMAGE):$(DOCKER_TAG)

docker-build:
	# Build Docker image
	docker build \
	--build-arg BUILD_DATE='date -u +"%Y-%m-%dT%H:%M:%SZ"' \
	--build-arg VERSION=$(CODE_VERSION) \
	--build-arg VCS_URL='git config --get remote.origin.url' \
	--build-arg VCS_REF=$(GIT_COMMIT) \
	--build-arg AWS_ENV_VERSION=$(AWS_ENV_LATEST_RELEASE) \
	-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Tag image as latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

output:
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)