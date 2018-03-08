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
	@echo "GOPATH"
	@echo "Get Brocaar Lora Server"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u github.com/brocaar/loraserver || true
	@echo "Brocaar Lora Server : building requirements"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin make requirements -C \
		$(@D)/src/github.com/brocaar/loraserver/
	@echo "Brocaar Lora Server : building executable"
	GOPATH=$(@D) PATH=$(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin/linux_arm:$(@D)/bin \
		GOOS=linux GOARCH=arm make build -C $(@D)/src/github.com/brocaar/loraserver/
endef

# Install the application into the rootfs file system
define LORA_SERVER_BROCAAR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/build/loraserver \
		$(TARGET_DIR)/usr/bin/loraserver
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/packaging/deb/init.sh \
		$(TARGET_DIR)/usr/lib/loraserver/scripts/init.sh
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/packaging/deb/loraserver.service \
		$(TARGET_DIR)/usr/lib/loraserver/scripts/loraserver.service
	$(INSTALL) -D -m 0755 $(@D)/src/github.com/brocaar/loraserver/packaging/deb/logrotate \
		$(TARGET_DIR)/etc/logrotate.d/loraserver
endef

$(eval $(generic-package))
