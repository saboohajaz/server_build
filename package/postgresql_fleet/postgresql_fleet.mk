################################################################################
#
# postgresql fleet
#
################################################################################

POSTGRESQL_FLEET_VERSION = 9.6.3
POSTGRESQL_FLEET_SOURCE = postgresql-$(POSTGRESQL_VERSION).tar.bz2
POSTGRESQL_FLEET_SITE = http://ftp.postgresql.org/pub/source/v$(POSTGRESQL_VERSION)
POSTGRESQL_FLEET_LICENSE = PostgreSQL
POSTGRESQL_FLEET_LICENSE_FILES = COPYRIGHT
POSTGRESQL_FLEET_INSTALL_STAGING = YES
POSTGRESQL_FLEET_CONFIG_SCRIPTS = pg_config
POSTGRESQL_FLEET_CONF_ENV = \
	ac_cv_type_struct_sockaddr_in6=yes \
	pgac_cv_snprintf_long_long_int_modifier="ll" \
	pgac_cv_snprintf_size_t_support=yes
POSTGRESQL_FLEET_CONF_OPTS = --disable-rpath

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
# PostgreSQL does not build against uClibc with locales
# enabled, due to an uClibc bug, see
# http://lists.uclibc.org/pipermail/uclibc/2014-April/048326.html
# so overwrite automatic detection and disable locale support
POSTGRESQL_FLEET_CONF_ENV += pgac_cv_type_locale_t=no
endif

ifneq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
POSTGRESQL_FLEET_CONF_OPTS += --disable-thread-safety
endif

ifeq ($(BR2_arcle)$(BR2_arceb)$(BR2_microblazeel)$(BR2_microblazebe)$(BR2_or1k)$(BR2_nios2)$(BR2_xtensa),y)
POSTGRESQL_FLEET_CONF_OPTS += --disable-spinlocks
endif

ifeq ($(BR2_PACKAGE_READLINE),y)
POSTGRESQL_FLEET_DEPENDENCIES += readline
else
POSTGRESQL_FLEET_CONF_OPTS += --without-readline
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
POSTGRESQL_FLEET_DEPENDENCIES += zlib
else
POSTGRESQL_FLEET_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_TZDATA),y)
POSTGRESQL_FLEET_DEPENDENCIES += tzdata
POSTGRESQL_FLEET_CONF_OPTS += --with-system-tzdata=/usr/share/zoneinfo
else
POSTGRESQL_FLEET_DEPENDENCIES += host-zic
POSTGRESQL_FLEET_CONF_ENV += ZIC="$(ZIC)"
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
POSTGRESQL_FLEET_DEPENDENCIES += openssl
POSTGRESQL_FLEET_CONF_OPTS += --with-openssl
endif

ifeq ($(BR2_PACKAGE_OPENLDAP),y)
POSTGRESQL_FLEET_DEPENDENCIES += openldap
POSTGRESQL_FLEET_CONF_OPTS += --with-ldap
else
POSTGRESQL_FLEET_CONF_OPTS += --without-ldap
endif

define POSTGRESQL_FLEET_USERS
	postgres -1 postgres -1 * /var/lib/pgsql /bin/sh - PostgreSQL Server
endef

define POSTGRESQL_FLEET_INSTALL_TARGET_FIXUP
	cd $(@D) && make -C contrib/pg_trgm all
	$(INSTALL) -dm 0700 $(TARGET_DIR)/var/lib/pgsql
	$(RM) -rf $(TARGET_DIR)/usr/lib/postgresql/pgxs
	mkdir -p $(TARGET_DIR)/usr/lib/postgresql/
	mkdir -p $(TARGET_DIR)/usr/share/postgresql/extension/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm.so $(TARGET_DIR)/usr/lib/postgresql/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm--1.0--1.1.sql $(TARGET_DIR)/usr/share/postgresql/extension/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm--1.1--1.2.sql $(TARGET_DIR)/usr/share/postgresql/extension/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm--1.2--1.3.sql $(TARGET_DIR)/usr/share/postgresql/extension/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm--1.3.sql $(TARGET_DIR)/usr/share/postgresql/extension/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm--unpackaged--1.0.sql $(TARGET_DIR)/usr/share/postgresql/extension/
	$(INSTALL) -m 0755 -D $(@D)/contrib/pg_trgm/pg_trgm.control $(TARGET_DIR)/usr/share/postgresql/extension/
endef

POSTGRESQL_FLEET_POST_INSTALL_TARGET_HOOKS += POSTGRESQL_FLEET_INSTALL_TARGET_FIXUP

define POSTGRESQL_FLEET_INSTALL_CUSTOM_PG_CONFIG
	$(INSTALL) -m 0755 -D package/postgresql/pg_config \
		$(STAGING_DIR)/usr/bin/pg_config
endef

POSTGRESQL_FLEET_POST_INSTALL_STAGING_HOOKS += POSTGRESQL_INSTALL_CUSTOM_PG_CONFIG

define POSTGRESQL_FLEET_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/postgresql/S50postgresql \
		$(TARGET_DIR)/etc/init.d/S50postgresql
endef

define POSTGRESQL_FLEET_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/postgresql/postgresql.service \
		$(TARGET_DIR)/usr/lib/systemd/system/postgresql.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs ../../../../usr/lib/systemd/system/postgresql.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/postgresql.service
endef

$(eval $(autotools-package))
