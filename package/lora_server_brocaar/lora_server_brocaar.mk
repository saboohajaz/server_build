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

# Build the source
define LORA_SERVER_BROCAAR_BUILD_CMDS
	# @echo "Brocaar Lora App Server : downloading"
	# @GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u github.com/brocaar/lora-app-server || true
	# @echo "Brocaar Lora App Server : building requirements"
	# GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make requirements -C \
	#	$(@D)/src/github.com/brocaar/lora-app-server/
	# GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make ui-requirements -C \
	#	$(@D)/src/github.com/brocaar/lora-app-server/
	# @echo "Brocaar Lora App Server : building executable"
	# GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin/linux_arm:$(@D)/bin \
	#	GOOS=linux GOARCH=arm make build -C $(@D)/src/github.com/brocaar/lora-app-server/
	# @echo "Brocaar Lora App Server : done"
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
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-gateway-bridge/packaging/deb/init.sh \
		$(TARGET_DIR)/usr/lib/lora-gateway-bridge/scripts/init.sh
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-gateway-bridge/packaging/deb/lora-gateway-bridge.service \
		$(TARGET_DIR)/usr/lib/lora-gateway-bridge/scripts/lora-gateway-bridge.service
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-gateway-bridge/packaging/deb/logrotate \
		$(TARGET_DIR)/etc/logrotate.d/lora-gateway-bridge
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/build/loraserver \
		$(TARGET_DIR)/usr/bin/loraserver
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/packaging/deb/init.sh \
		$(TARGET_DIR)/usr/lib/loraserver/scripts/init.sh
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/packaging/deb/loraserver.service \
		$(TARGET_DIR)/usr/lib/loraserver/scripts/loraserver.service
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/packaging/deb/logrotate \
		$(TARGET_DIR)/etc/logrotate.d/loraserver
	# $(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-app-server/build/lora-app-server \
	#	$(TARGET_DIR)/usr/bin/lora-app-server
	# $(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-app-server/packaging/deb/init.sh \
	#	$(TARGET_DIR)/usr/lib/lora-app-server/scripts/init.sh
	# $(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-app-server/packaging/deb/lora-app-server.service \
	#	$(TARGET_DIR)/usr/lib/lora-app-server/scripts/lora-app-server.service
	# $(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/lora-app-server/packaging/deb/logrotate \
	#	$(TARGET_DIR)/etc/logrotate.d/lora-app-server
endef

$(eval $(generic-package))
