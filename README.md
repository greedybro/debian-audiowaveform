# debian-audiowaveform

## Introduction

Provides debian package building tools for audiowaveform :

- Uses docker to pull and build an image of debian from dockerfiles
- Uses github releases of audiowaveform as sources
- Uses debian tools to build packages

## Basic Usage

- Modify `Makefile` variables section accordingly to the release you want to package, and the revisions of the package.
- Modify `Dockerfiles` variables accordingly to the name and email of the maintainer.
- Execute `make package.%` (Replace `%` with wanted release distribution)

```
	PACKAGE_VERSION = 1.4.1
	PACKAGE_REVISION = 1
	PACKAGE_REVISION_DISTRIBUTION = 1
	PACKAGE_SOURCE = https://github.com/bbc/audiowaveform/archive/$(PACKAGE_VERSION).tar.gz
```
```shell:
	make package.buster
```

## Detailled

### make dev.%

Pull, build and exec the docker container.
Replace `%` with wanted release distribution.

### make update

Execute `apt-get update` and `apt-get -y dist-upgrade`

### make clean.%

Delete sources directory
Replace `%` with wanted release distribution.

### make checkout.%

cURL the release you specified in variables and extract it in a directory named as the release distribution.
Replace `%` with wanted release distribution.

### make prepare/%

Modify the changelog of the future release. Name and mail address can be changed in dockerfiles.
Replace `%` with wanted release distribution.

### make dependencies/%

Install build dependencies specified in `debian/control`.
Replace `%` with wanted release distribution.

### make build/%

Package the `.deb` for specified release distribution.
Replace `%` with wanted release distribution.

### make package.%

Execute all of the following tasks : `make update checkout.% prepare.% dependencies.% build.%`
Replace `%` with wanted release distribution.
