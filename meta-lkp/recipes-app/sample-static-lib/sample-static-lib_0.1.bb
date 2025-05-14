DESCRIPTION = "Simple hello world static library"
LICENSE = "CLOSED"

# SRC_URI = "file://src/arith.c \
#            file://src/print.c \
#            file://include/arith.h \
#            file://include/print.h \
#            file://static_check.c \
#            file://Makefile"

SRC_URI = "file://src \
           file://include \
           file://static_check.c \
           file://Makefile"

B = "${WORKDIR}"
S = "${WORKDIR}"

#############################
## https://stackoverflow.com/questions/79382855/building-a-recipe-fails-on-yocto-styhead-because-bitbake-doesnt-move-the-source
## since styhead release.
#############################
# S = "${WORKDIR}/sources"
# UNPACKDIR = "${S}"
############################

do_compile:append() {
        bbplain "pwd: $(pwd)"
        bbplain "ls -al: $(ls -al)"
        bbplain "UNPACKDIR: ${UNPACKDIR}"
        bbplain "ls -al ${UNPACKDIR}: $(ls -al ${UNPACKDIR})"
        oe_runmake all
        # ${CC} -c print.c
        # ${CC} -c arith.c
        # # ${CC} -c my_static_lib.c
        # # ${AR} rcs libmystatic.a print.o arith.o my_static_lib.o
        # ${AR} rcs libmystatic.a print.o arith.o
        ${CC} ${LDFLAGS} static_check.c -o static_check -L./ -I./include -lmystatic
}

do_install() {
        install -d ${D}${libdir}
        install -m 0755 libmystatic.a ${D}${libdir}
        install -d ${D}${includedir}
        install -m 0644 include/my_static_lib.h ${D}${includedir}
        install -d ${D}${bindir}
        install -m 0755 static_check ${D}${bindir}
}

FILE:${PN} += " ${includedir}/my_static_lib.h"