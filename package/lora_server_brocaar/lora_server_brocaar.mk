###############################################
#
# Lora Server Brocaar
#
###############################################
# Download source from github
LORA_SERVER_BROCAAR_SITE_INSTALL_STAGING = YES
LORA_SERVER_BROCAAR_DEPENDENCIES = mosquitto
LORA_SERVER_BROCAAR_DEPENDENCIES += redis
LORA_SERVER_BROCAAR_DEPENDENCIES += postgresql
LORA_SERVER_BROCAAR_DEPENDENCIES += host-go_fleet
LORA_SERVER_BROCAAR_DEPENDENCIES += host-nodejs

# Build the source
define LORA_SERVER_BROCAAR_BUILD_CMDS
	@echo "Brocaar Lora App Server : downloading"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u github.com/brocaar/lora-app-server || true
	cp $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar/Makefile \
		$(@D)/src/github.com/brocaar/lora-app-server/Makefile
	@cd $(@D)/src/github.com/brocaar/lora-app-server/ui && $(NPM) install

	@echo "Brocaar Lora App Server : building requirements"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make requirements \
		ui-requirements -C $(@D)/src/github.com/brocaar/lora-app-server/
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make clean \
		-C $(@D)/src/github.com/brocaar/lora-app-server/
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make api \
		-C $(@D)/src/github.com/brocaar/lora-app-server/
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make test \
		-C $(@D)/src/github.com/brocaar/lora-app-server/
	@cd $(@D)/src/github.com/brocaar/lora-app-server/ui && $(NPM) run build

	@echo "Brocaar Lora App Server : building executable"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin/linux_arm:$(@D)/bin \
		GOOS=linux GOARCH=arm make -B build -C $(@D)/src/github.com/brocaar/lora-app-server/

	@echo "Brocaar Lora App Server : done"

	@echo "Brocaar Lora Gateway Bridge : downloading"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u github.com/brocaar/lora-gateway-bridge || true

	@echo "Brocaar Lora Gateway Bridge : building requirements"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make requirements -C \
		$(@D)/src/github.com/brocaar/lora-gateway-bridge/

	@echo "Brocaar Lora Gateway Bridge : building executable"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin/linux_arm:$(@D)/bin \
		GOOS=linux GOARCH=arm make build -C $(@D)/src/github.com/brocaar/lora-gateway-bridge/

	@echo "Brocaar Lora Gateway Bridge : done"

	@echo "Brocaar Lora Server : downloading"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u github.com/brocaar/loraserver || true

	@echo "Brocaar Lora Server : building requirements"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make requirements -C \
		$(@D)/src/github.com/brocaar/loraserver/

	@echo "Brocaar Lora Server : building executable"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin/linux_arm:$(@D)/bin \
		GOOS=linux GOARCH=arm make build -C $(@D)/src/github.com/brocaar/loraserver/

	@echo "Brocaar Lora Server : done"
endef

# Install the application into the rootfs file system
define LORA_SERVER_BROCAAR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-gateway-bridge/build/lora-gateway-bridge \
		$(TARGET_DIR)/usr/bin/lora-gateway-bridge
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar/lora-gateway-bridge.toml \
		$(TARGET_DIR)/etc/lora-gateway-bridge/lora-gateway-bridge.toml

	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/build/loraserver \
		$(TARGET_DIR)/usr/bin/loraserver
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar/loraserver.toml \
		$(TARGET_DIR)/etc/loraserver/loraserver.toml

	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-app-server/build/lora-app-server \
		$(TARGET_DIR)/usr/bin/lora-app-server
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar/lora-app-server.toml \
		$(TARGET_DIR)/etc/lora-app-server/lora-app-server.toml
endef

define LORA_SERVER_BROCAAR_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar/loraServer \
		$(TARGET_DIR)/etc/init.d/S$(BR2_LORA_SERVER_BROCAAR_INIT_LVL)loraServer
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar/loraServerInit \
		$(TARGET_DIR)/usr/sbin/loraServer/loraServerInit
endef


$(eval $(generic-package))
