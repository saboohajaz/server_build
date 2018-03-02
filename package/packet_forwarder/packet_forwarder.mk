###############################################
#
# Packet Forwarder
#
###############################################
# Download source from github
PACKET_FORWARDER_VERSION = 4.0.1
PACKET_FORWARDER_SITE = https://github.com/Lora-net/packet_forwarder/archive/v$(PACKET_FORWARDER_VERSION)
PACKET_FORWARDER_SITE_INSTALL_STAGING = YES

# Build the source
define PACKET_FORWARDER_BUILD_CMDS
	make CROSS_COMPILE=$(TARGET_CROSS) ARCH=armv7l -C $(@D)
	cp $(@D)/lora_pkt_fwd/global_conf.json $(@D)/lora_pkt_fwd/cfg/global_conf.json.default
endef

# Install the application into the rootfs file system
define PACKET_FORWARDER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin/packet_forwarder/ 
	cp -R $(@D)/* $(TARGET_DIR)/usr/bin/packet_forwarder/
	$(INSTALL) -D -m 0755 -b $(BR2_EXTERNAL_PORTAL_PATH)/package/packet_forwarder/global_conf.json.AUS \
		$(TARGET_DIR)/usr/bin/packet_forwarder/lora_pkt_fwd/cfg/global_conf.json.AUS
	$(INSTALL) -D -m 0755 -b $(BR2_EXTERNAL_PORTAL_PATH)/package/packet_forwarder/global_conf.json.AUS \
		$(TARGET_DIR)/usr/bin/packet_forwarder/lora_pkt_fwd/global_conf.json
endef

$(eval $(generic-package))
