###############################################
#
# Packet Forwarder
#
###############################################
# Download source from github
PACKET_FORWARDER_VERSION = 4.0.1
PACKET_FORWARDER_SITE = https://github.com/Lora-net/packet_forwarder/archive/v$(PACKET_FORWARDER_VERSION)
PACKET_FORWARDER_SITE_INSTALL_STAGING = YES
PACKET_FORWARDER_DEPENDENCIES = loragateway
PACKET_FORWARDER_OLD_ID := AA555A0000000000
# Build the source
define PACKET_FORWARDER_BUILD_CMDS
	make CROSS_COMPILE=$(TARGET_CROSS) ARCH=armv7l -C $(@D)
	cp $(@D)/lora_pkt_fwd/global_conf.json $(@D)/lora_pkt_fwd/cfg/global_conf.json.default
	$(eval PACKET_FORWARDER_ID := $(shell grep -Po '"gateway_ID":.*?[^\\]"*?[^\\]"' $(@D)/lora_pkt_fwd/local_conf.json|cut -d'"' -f4))
	$(INSTALL) -D -m 0766 $(BR2_EXTERNAL_PORTAL_PATH)/package/packet_forwarder/global_conf.json.AUS \
		$(@D)/lora_pkt_fwd/cfg/global_conf.json.AUS
	$(INSTALL) -D -m 0766 $(BR2_EXTERNAL_PORTAL_PATH)/package/packet_forwarder/global_conf.json.AUS \
		$(@D)/lora_pkt_fwd/global_conf.json
	sed -i 's/$(PACKET_FORWARDER_OLD_ID)/$(PACKET_FORWARDER_ID)/g' $(@D)/lora_pkt_fwd/global_conf.json
	sed -i 's/$(PACKET_FORWARDER_OLD_ID)/$(PACKET_FORWARDER_ID)/g' $(@D)/lora_pkt_fwd/cfg/*
endef

# Install the application into the rootfs file system
define PACKET_FORWARDER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin/packet_forwarder/ 
	cp -R $(@D)/* $(TARGET_DIR)/usr/bin/packet_forwarder/
endef

$(eval $(generic-package))
