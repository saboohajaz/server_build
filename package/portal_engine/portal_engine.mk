###############################################
#
# PORTAL_ENGINE
#
###############################################

PORTAL_ENGINE_DEPENDENCIES += host-go_fleet
PORTAL_ENGINE_DEPENDENCIES += lora_server_brocaar
PORTAL_ENGINE_SRC_PATH = bitbucket.org/fleetspace/nano-analytics
PORTAL_ENGINE_SRC_DIR = $(@D)/src/$(PORTAL_ENGINE_SRC_PATH)/
PORTAL_ENGINE_INIT_LVL = $(shell echo $$(( $(BR2_PACKAGE_LORA_SERVER_BROCAAR_INIT_LVL) + 1 )))
PORTAL_ENGINE_DR = $(BR2_EXTERNAL_PORTAL_PATH)/package/portal_engine

define PORTAL_ENGINE_BUILD_CMDS
	@echo "Build Portal Engine"
	GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u $(PORTAL_ENGINE_SRC_PATH) || true
	cd $(PORTAL_ENGINE_SRC_DIR) && GOPATH=$(@D) GOOS=linux GOARCH=arm $(HOST_GO_FLEET_ROOT)/bin/go build -o PortalEngine main.go
endef

define PORTAL_ENGINE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/opt/PortalEngine/
	$(INSTALL) -D -m 0755 $(PORTAL_ENGINE_SRC_DIR)/PortalEngine $(TARGET_DIR)/opt/PortalEngine/
	pwd
	$(INSTALL) -D -m 0755 $(PORTAL_ENGINE_DR)/PortalEngineService $(TARGET_DIR)/etc/init.d/S$(PORTAL_ENGINE_INIT_LVL)PortalEngineService
endef

$(eval $(generic-package))

