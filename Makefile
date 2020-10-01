.SILENT:
.PHONY: dev update checkout prepare dependencies build package

#############
# Variables #
#############

PACKAGE = audiowaveform
PACKAGE_VERSION = 1.4.2
PACKAGE_REVISION = 1
PACKAGE_REVISION_DISTRIBUTION = 1
PACKAGE_SOURCE = https://github.com/bbc/audiowaveform/archive/$(PACKAGE_VERSION).tar.gz

##############
# Docker_run #
##############

define docker_run
	ID=$$( \
			docker build \
				--quiet \
				-f Dockerfile.$(DISTRIBUTION) . \
		) \
		&& docker run \
			--rm \
			--tty \
			--volume `pwd`:/srv \
			--interactive \
			$${ID} \
			$(if $(1),$(strip $(1)),bash)
endef

#######
# Dev #
#######

dev:
	$(call docker_run)

dev.jessie: DISTRIBUTION = jessie
dev.jessie: dev

dev.stretch: DISTRIBUTION = stretch
dev.stretch: dev

dev.buster: DISTRIBUTION = buster
dev.buster: dev

#########
# Clean #
#########

clean:
	rm -r \
		./$(DISTRIBUTION)

clean.jessie: DISTRIBUTION = jessie
clean.jessie: clean

clean.stretch: DISTRIBUTION = stretch
clean.stretch: clean

clean.buster: DISTRIBUTION = buster
clean.buster: clean


update:
	apt-get update
	apt-get -y dist-upgrade

############
# Checkout #
############

checkout:
	mkdir --p $(DISTRIBUTION)/$(PACKAGE)
	curl --location $(PACKAGE_SOURCE) | bsdtar -zxf - -C $(DISTRIBUTION)/$(PACKAGE) --strip-components=1
	curl --location https://github.com/google/googletest/archive/release-1.10.0.tar.gz | bsdtar -zxf - -C $(DISTRIBUTION)/$(PACKAGE)
	ln -s googletest-release-1.10.0/googletest $(DISTRIBUTION)/$(PACKAGE)/googletest
	ln -s googletest-release-1.10.0/googlemock $(DISTRIBUTION)/$(PACKAGE)/googlemock

checkout.jessie: DISTRIBUTION = jessie
checkout.jessie: checkout

checkout.stretch: DISTRIBUTION = stretch
checkout.stretch: checkout

checkout.buster: DISTRIBUTION = buster
checkout.buster: checkout

###########
# Prepare #
###########

prepare:
	cd $(DISTRIBUTION)/$(PACKAGE)/debian && \
	dch --newversion $(PACKAGE_VERSION)-$(PACKAGE_REVISION)$(DISTRIBUTION)$(PACKAGE_REVISION_DISTRIBUTION) "Packaging .deb for release $(PACKAGE_VERSION)" -u "low" && \
	dch --release ""

prepare.jessie: DISTRIBUTION = jessie
prepare.jessie: prepare

prepare.stretch: DISTRIBUTION = stretch
prepare.stretch: prepare

prepare.buster: DISTRIBUTION = buster
prepare.buster: prepare

################
# Dependencies #
################

dependencies:
	cd $(DISTRIBUTION)/$(PACKAGE) && \
	mk-build-deps \
		--install --remove --root-cmd sudo \
		--tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" \
		debian/control

dependencies.jessie: DISTRIBUTION = jessie
dependencies.jessie: dependencies

dependencies.stretch: DISTRIBUTION = stretch
dependencies.stretch: dependencies

dependencies.buster: DISTRIBUTION = buster
dependencies.buster: dependencies

#########
# Build #
#########

build:
	cd $(DISTRIBUTION)/$(PACKAGE) && \
		debuild --no-lintian -us -uc -b

build.jessie: DISTRIBUTION = jessie
build.jessie: build

build.stretch: DISTRIBUTION = stretch
build.stretch: build

build.buster: DISTRIBUTION = buster
build.buster: build

###########
# Package #
###########

package:
	$(call docker_run, \
		make update \
			 checkout.$(DISTRIBUTION) \
			 prepare.$(DISTRIBUTION) \
			 dependencies.$(DISTRIBUTION) \
			 build.$(DISTRIBUTION))

package.jessie: DISTRIBUTION = jessie
package.jessie: package

package.stretch: DISTRIBUTION = stretch
package.stretch: package

package.buster: DISTRIBUTION = buster
package.buster: package
