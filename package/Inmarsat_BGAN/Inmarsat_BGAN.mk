###############################################
#
# Inmarsat BGAN
#
###############################################

INMARSAT_BGAN_DEPENDENCIES = rp-pppoe
INMARSAT_BGAN_DEPENDENCIES += pppd
INMARSAT_BGAN_DR = $(BR2_EXTERNAL_PORTAL_PATH)/package/Inmarsat_BGAN

# Install the application into the rootfs file system
define INMARSAT_BGAN_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/opt/Inmarsat/ 
	$(INSTALL) -D -m 0755 $(INMARSAT_BGAN_DR)/inmarsat_bgan_setup $(TARGET_DIR)/opt/Inmarsat/ 
	mkdir -p $(TARGET_DIR)/etc/ppp/peers/
	$(INSTALL) -D -m 0755 $(INMARSAT_BGAN_DR)/chap-secrets $(TARGET_DIR)/etc/ppp/
	$(INSTALL) -D -m 0755 $(INMARSAT_BGAN_DR)/pap-secrets $(TARGET_DIR)/etc/ppp/
	$(INSTALL) -D -m 0755 $(INMARSAT_BGAN_DR)/resolv.conf $(TARGET_DIR)/etc/ppp/
	$(INSTALL) -D -m 0755 $(INMARSAT_BGAN_DR)/provider $(TARGET_DIR)/etc/ppp/peers/ 
endef

$(eval $(generic-package))
