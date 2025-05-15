DESCRIPTION = "Simple helloworld application"
LICENSE = "CLOSED"

B = "${WORKDIR}"
S = "${WORKDIR}"

#############################
## https://stackoverflow.com/questions/79382855/building-a-recipe-fails-on-yocto-styhead-because-bitbake-doesnt-move-the-source
## since styhead release.
#############################
# S = "${WORKDIR}/sources"
# UNPACKDIR = "${S}"
############################

SRC_URI = "file://src \
           file://include \
           file://Makefile"

LKP_HELLOWORLD_TARGET := "lkp_helloworld"

TARGET_CC_ARCH += "${LDFLAGS}"

BB_GDB_SYMBOL_ENABLE = "${@'1' if d.getVar('CS_APP_DEBUG_BULD') == '1' else '0'}"
EXTRA_OEMAKE += "LKP_HELLOWORLD_TARGET=${LKP_HELLOWORLD_TARGET}"
EXTRA_OEMAKE += "LKP_HELLOWORLD_INCLUDE_PATH=${STAGING_DIR_TARGET}${includedir}"

DEPENDS += "sample-static-lib"

do_compile() {
    # bbplain "do_compile(): CC=${CC}, CROSS_COMPILE=${CROSS_COMPILE}"

    # ${CC} lkp_helloworld.c ${LDFLAGS} -o lkp_helloworld
    oe_runmake
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 lkp_helloworld ${D}${bindir}/lkp_helloworld
}

FILES:${PN} += "${bindir}/lkp_helloworld"
# To use this as service
# RPROVIDES_${PN} = "lkp-helloworld"
