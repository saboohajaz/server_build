###############################################
#
# Lora Gateway
#
###############################################
# Download source from github
LORAGATEWAY_VERSION = 5.0.1
LORAGATEWAY_SITE = https://github.com/Lora-net/lora_gateway/archive/v$(LORAGATEWAY_VERSION)
LORAGATEWAY_SITE_INSTALL_STAGING = YES

# Build the source
# Add flags to enable DEBUGs : DEBUG_AUX=1 DEBUG_SPI=1 DEBUG_REG=1 
define LORAGATEWAY_BUILD_CMDS
	make CROSS_COMPILE=$(TARGET_CROSS) ARCH=armv7l -C $(@D)
	cd $(@D)/.. && ln -s $(@D) lora_gateway
endef

# Install the application into the rootfs file system
define LORAGATEWAY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin/lora_gateway/ 
	cp -R $(@D)/* $(TARGET_DIR)/usr/bin/lora_gateway/
endef

$(eval $(generic-package))
