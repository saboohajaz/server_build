#!/bin/sh

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

for var in "$@"
do
echo $var
case "$var" in
    --add-pi3-miniuart-bt-overlay)
    if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
	    echo "Adding 'dtoverlay=pi3-miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
	    cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi3 ttyAMA0 serial console
dtoverlay=pi3-miniuart-bt
__EOF__
    fi
    ;;
    --aarch64)
    # Run a 64bits kernel (armv8)
    sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
    if ! grep -qE '^arm_control=0x200' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
	    cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_control=0x200
__EOF__
    fi
    # Enable uart console
    if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
	    cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable rpi3 ttyS0 serial console
enable_uart=1
__EOF__
    fi
    ;;
    --add-spi=on-param)
    if ! grep -qE '^dtparam=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
	    echo "Adding 'dtparam=spi=on' to config.txt (enable SPI)."
	    cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# Enable SPI
dtparam=spi=on
__EOF__
    fi
    ;;
esac
done


rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
