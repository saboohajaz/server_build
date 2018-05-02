###############################################
#
# Lora Server Brocaar
#
###############################################
# Download source from github
LORA_SERVER_BROCAAR_SITE_INSTALL_STAGING = YES
LORA_SERVER_BROCAAR_DEPENDENCIES = mosquitto
LORA_SERVER_BROCAAR_DEPENDENCIES += redis
LORA_SERVER_BROCAAR_DEPENDENCIES += postgresql_fleet
LORA_SERVER_BROCAAR_DEPENDENCIES += host-go_fleet
LORA_SERVER_BROCAAR_DEPENDENCIES += host-nodejs
LORA_SERVER_BROCAAR_DEPENDENCIES += host-protobuf

LORA_SERVER_BROCAAR_NET_SERV_VER = 0.26.1
LORA_SERVER_BROCAAR_APP_SERV_VER = fleet-0.20.1
LORA_SERVER_BROCAAR_BRD_SERV_VER = 2.4.0

LORA_SERVER_BROCAAR_GITHUB = github.com/brocaar
LORA_SERVER_BROCAAR_FLEET_BITBUCKET = bitbucket.org/fleetspace
LORA_SERVER_BROCAAR_N = loraserver
LORA_SERVER_BROCAAR_A = lora-app-server
LORA_SERVER_BROCAAR_B = lora-gateway-bridge
LORA_SERVER_BROCAAR_NS = $(LORA_SERVER_BROCAAR_GITHUB)/$(LORA_SERVER_BROCAAR_N)
LORA_SERVER_BROCAAR_AS = $(LORA_SERVER_BROCAAR_FLEET_BITBUCKET)/$(LORA_SERVER_BROCAAR_A)
LORA_SERVER_BROCAAR_BS = $(LORA_SERVER_BROCAAR_GITHUB)/$(LORA_SERVER_BROCAAR_B)
LORA_SERVER_BROCAAR_SNS = src/$(LORA_SERVER_BROCAAR_NS)
LORA_SERVER_BROCAAR_SAS = src/$(LORA_SERVER_BROCAAR_AS)
LORA_SERVER_BROCAAR_SBS = src/$(LORA_SERVER_BROCAAR_BS)
LORA_SERVER_BROCAAR_DR = $(BR2_EXTERNAL_PORTAL_PATH)/package/lora_server_brocaar
LORA_SERVER_BROCAAR_PTH = $(PATH):$(HOST_GO_FLEET_ROOT)/bin:$(@D)/bin:$(HOST_DIR)/usr/bin:$(@D)/bin/linux_arm

# Build the source
define LORA_SERVER_BROCAAR_BUILD_CMDS
	@echo "Brocaar Lora App Server : downloading"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u $(LORA_SERVER_BROCAAR_AS) || true
	#mkdir -p $(@D)/src/golang.org/x
	#cd $(@D)/src/golang.org/x && rm -Rf lint && git clone https://go.googlesource.com/lint
	#@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u golang.org/x/tools/... || true
	#@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u golang.org/x/lint/golint || true
	cd $(@D)/$(LORA_SERVER_BROCAAR_SAS) && git checkout tags/$(LORA_SERVER_BROCAAR_APP_SERV_VER)
	cp $(LORA_SERVER_BROCAAR_DR)/Makefile $(@D)/$(LORA_SERVER_BROCAAR_SAS)/Makefile
	@cd $(@D)/$(LORA_SERVER_BROCAAR_SAS)/ui && $(NPM) install

	@echo "Brocaar Lora App Server : building requirements"
	GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) make requirements ui-requirements -C $(@D)/$(LORA_SERVER_BROCAAR_SAS)/
	#GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) make clean -C $(@D)/$(LORA_SERVER_BROCAAR_SAS)/
	#GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) make api -C $(@D)/$(LORA_SERVER_BROCAAR_SAS)/
	@cd $(@D)/$(LORA_SERVER_BROCAAR_SAS)/ui && $(NPM) run build

	@echo "Brocaar Lora App Server : building executable"
	GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) GOOS=linux GOARCH=arm make -B build -C $(@D)/$(LORA_SERVER_BROCAAR_SAS)/

	@echo "Brocaar Lora App Server : done"

	@echo "Brocaar Lora Gateway Bridge : downloading"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u $(LORA_SERVER_BROCAAR_BS) || true
	cd $(@D)/$(LORA_SERVER_BROCAAR_SBS) && git checkout tags/$(LORA_SERVER_BROCAAR_BRD_SERV_VER)

	@echo "Brocaar Lora Gateway Bridge : building requirements"
	GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) make requirements -C $(@D)/$(LORA_SERVER_BROCAAR_SBS)/

	@echo "Brocaar Lora Gateway Bridge : building executable"
	GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) GOOS=linux GOARCH=arm make build -C $(@D)/$(LORA_SERVER_BROCAAR_SBS)/

	@echo "Brocaar Lora Gateway Bridge : done"

	@echo "Brocaar Lora Server : downloading"
	@GOPATH=$(@D) $(HOST_GO_FLEET_ROOT)/bin/go get -u $(LORA_SERVER_BROCAAR_NS) || true
	cd $(@D)/$(LORA_SERVER_BROCAAR_SNS) && git checkout tags/$(LORA_SERVER_BROCAAR_NET_SERV_VER)

	@echo "Brocaar Lora Server : building requirements"
	GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) make requirements -C $(@D)/$(LORA_SERVER_BROCAAR_SNS)/

	@echo "Brocaar Lora Server : building executable"
	GOPATH=$(@D) PATH=$(LORA_SERVER_BROCAAR_PTH) GOOS=linux GOARCH=arm make build -C $(@D)/$(LORA_SERVER_BROCAAR_SNS)/

	@echo "Brocaar Lora Server : done"
endef

# Install the application into the rootfs file system
define LORA_SERVER_BROCAAR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/$(LORA_SERVER_BROCAAR_SBS)/build/lora-gateway-bridge $(TARGET_DIR)/usr/bin/lora-gateway-bridge
	$(INSTALL) -D -m 0755 $(LORA_SERVER_BROCAAR_DR)/lora-gateway-bridge.toml $(TARGET_DIR)/etc/lora-gateway-bridge/lora-gateway-bridge.toml

	$(INSTALL) -D -m 0755 $(@D)/$(LORA_SERVER_BROCAAR_SNS)/build/loraserver $(TARGET_DIR)/usr/bin/loraserver
	$(INSTALL) -D -m 0755 $(LORA_SERVER_BROCAAR_DR)/loraserver.toml $(TARGET_DIR)/etc/loraserver/loraserver.toml

	$(INSTALL) -D -m 0755 $(@D)/$(LORA_SERVER_BROCAAR_SAS)/build/lora-app-server $(TARGET_DIR)/usr/bin/lora-app-server
	$(INSTALL) -D -m 0755 $(LORA_SERVER_BROCAAR_DR)/lora-app-server.toml $(TARGET_DIR)/etc/lora-app-server/lora-app-server.toml
	mkdir -p $(TARGET_DIR)/usr/sbin/loraServer
	date "+%Y-%m-%d %H:%M:%S" > $(TARGET_DIR)/usr/sbin/loraServer/buildtime
endef

define LORA_SERVER_BROCAAR_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(LORA_SERVER_BROCAAR_DR)/loraServer $(TARGET_DIR)/etc/init.d/S$(BR2_PACKAGE_LORA_SERVER_BROCAAR_INIT_LVL)loraServer
	$(INSTALL) -D -m 0755 $(LORA_SERVER_BROCAAR_DR)/loraServerInit $(TARGET_DIR)/usr/sbin/loraServer/loraServerInit
endef

$(eval $(generic-package))
