###############################################
#
# PORTAL_ENGINE
#
###############################################

#PORTAL_ENGINE_VERSION = master
#PORTAL_ENGINE_SITE = https://bitbucket.org/fleetspace/nano-analytics
#PORTAL_ENGINE_SOURCE = portal_engine-$(PORTAL_ENGINE_VERSION).tar.gz
#PORTAL_ENGINE_SITE_METHOD = git

PORTAL_ENGINE_DEPENDENCIES += host-go_fleet
PORTAL_ENGINE_SRC_DIR = $(@D)/src/bitbucket.org/fleetspace/nano-analytics/


define PORTAL_ENGINE_BUILD_CMDS
	@echo "Build Portal Engine"
	GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u bitbucket.org/fleetspace/nano-analytics || true
	cd $(PORTAL_ENGINE_SRC_DIR) && GOPATH=$(PORTAL_ENGINE_SRC_DIR) GOOS=linux GOARCH=arm $(HOST_GO_FLEET_ROOT)/bin/go build -o PortalEngine main.go
endef

define PORTAL_ENGINE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/opt/PortalEngine/ 
endef

$(eval $(generic-package))

