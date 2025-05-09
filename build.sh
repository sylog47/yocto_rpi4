#!/bin/bash

function get_layers()
{
    echo "--- $FUNCNAME ---"
    if [ ! -d poky ]; then
    	echo "poky doesn't exist!!! Get new one..."
    	git clone -b scarthgap git://git.yoctoproject.org/poky -b scarthgap
    fi

    if [ ! -d meta-raspberrypi ]; then
    	echo "meta-raspberrypi doesn't exist!!! Get new one..."
    	git clone -b scarthgap git://git.yoctoproject.org/meta-raspberrypi
    fi
}

function setup_layers()
{
    echo "--- $FUNCNAME ---"
    echo "init workspace..."
    BUILD_DIR=$1
    LKP_LAYER=$2
    CUR_DIR=`pwd`

    echo "BUILD_DIR: ${BUILD_DIR}"
    echo "LKP_LAYER: ${LKP_LAYER}"

    source poky/oe-init-build-env  ${BUILD_DIR}


    bitbake-layers show-layers

    echo "---- Add meta-raspberrypi layer..."
    bitbake-layers add-layer ../meta-raspberrypi

    if [[ "${LKP_LAYER}" == "qemu-lkp" ]]; then
        echo "Setup additional ${LKP_LAYER}"
        if [ ! -d ../meta-lkp ]; then
            echo "Create new layer(meta-lkp)"
            bitbake-layers create-layer ../meta-lkp
        else
            echo "qemu-lkp layer is already exist!"
        fi

        bitbake-layers add-layer ../meta-lkp

        CUR_DIR=`pwd`
        cd ../meta-lkp
        if [ ! -d recipes-core/images ]; then
            echo "Create new images in meta-lkp layer"
            mkdir -p recipes-core/images
            cp -vrf ../poky/meta/recipes-core/images/* recipes-core/images/
            tree .
        fi

        if [ ! -f recipes-core/images/lkp-image.bb ]; then
            echo "Create new lkp-image recipe"
            cp -v recipes-core/images/core-image-minimal.bb recipes-core/images/lkp-image.bb
        fi
        cd $CUR_DIR


    elif [[ "${LKP_LAYER}" == "rpi4-lkp" ]]; then
        echo "Setup additional rpi4 lkp layer"
    elif [[ "${LKP_LAYER}" == "rpi0-2w-lkp" ]]; then
        echo "Setup additional rpi0-2w lkp layer"
    else
        echo "Invalid layer"
    fi

    echo "Current Layers:"
    bitbake-layers show-layers

    echo "--------------------"
}

function configure_build()
{
    echo "--- $FUNCNAME ---"
    LOCAL_CONF_PATH=$1
    # MY_MACHINE=raspberrypi4
    MY_MACHINE=$2

    echo "LOCAL_CONF_PATH: ${LOCAL_CONF_PATH}"

    if grep -q "PARALLEL_MAKE" "${LOCAL_CONF_PATH}"; then
        echo "already configured(PARALLEL MAKE) done."
    else
        echo 'PARALLEL_MAKE = "-j 12"' >> ${LOCAL_CONF_PATH}
    fi

    if grep -q "BB_NUMBER_THREADS" "${LOCAL_CONF_PATH}"; then
        echo "already configured(BB_NUMBER_THREADS) done."
    else
        echo 'BB_NUMBER_THREADS = "24"' >> ${LOCAL_CONF_PATH}
    fi

    # save disk by removing working directory except necessary core packages.
    if grep -q "rm_work" "${LOCAL_CONF_PATH}"; then
        echo "already configured(rm_work) done."
    else
        # save disk by removing working directory except necessary core packages.
        echo 'INHERIT += "rm_work"' >> ${LOCAL_CONF_PATH}

        # we needs kernel, u-boot working directory.
        # https://stackoverflow.com/questions/52826437/new-yocto-recipe-builds-but-work-directory-is-deleted-after-compilation
        # RM_WORK_EXCLUDE += "zbar"
        # echo 'RM_WORK_EXCLUDE += "virtual/kernel"' >> ${LOCAL_CONF_PATH}

        # doesnt't work..
        # echo 'RM_WORK_EXCLUDE += "virtual/bootloader"' >> ${LOCAL_CONF_PATH}

        # use this instead of virtual/bootloader
        # echo 'RM_WORK_EXCLUDE += "u-boot-socfpga"' >> ${LOCAL_CONF_PATH}

        # use local Arm Trusted Firmware instead of cloning git code.
        # echo 'RM_WORK_EXCLUDE += "arm-trusted-firmware"' >> ${LOCAL_CONF_PATH}
    fi

    #########################################################################################
    # To share packages with differnt build directories.
    # (refernece url) https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/60129817/\
    # Xilinx+Yocto+Builds+without+an+Internet+Connection?view=blog
    # The downloads directory is where all the source packages are downloaded locally.
    #    This directory may be relocated with the DL_DIR variable in your local.conf.
    # The sstate-cache directory is where all the build artifacts are cached
    #    which can be reused to accelerate subsequent builds.
    #    This directory may be relocated with the SSTATE_DIR variable in your local.conf.
    #----------------------------------------------------------------------------------------
    if grep -q "#DL_DIR ?= " "${LOCAL_CONF_PATH}"; then
        sed -i "s/#DL_DIR ?=/DL_DIR ?=/g"  ${LOCAL_CONF_PATH}
        #echo 'DL_DIR ?= "${TOPDIR}/downloads"' >> ${LOCAL_CONF_PATH}
    fi

    if grep -q "SSTATE_DIR" "${LOCAL_CONF_PATH}"; then
        echo "already configured(SSTATE_DIR) done."
    else
        echo 'SSTATE_DIR ?= "${TOPDIR}/sstate-cache"' >> ${LOCAL_CONF_PATH}
    fi

    # Disable default MACHINE declaration
    sed -i "s/MACHINE ??= /#MACHINE ??= /g"  ${LOCAL_CONF_PATH}

#    if grep -q "MACHINE := \"$MY_MACHINE\""  "${LOCAL_CONF_PATH}"; then
#        echo "MACHINE is already configured!"
#    else
    if ! grep -q "MACHINE := \"$MY_MACHINE\""  "${LOCAL_CONF_PATH}"; then
        echo "MACHINE := \"$MY_MACHINE\"" >> ${LOCAL_CONF_PATH}
    fi

    if [[ "${MY_MACHINE}" == "raspberrypi4" || "${MY_MACHINE}" == "raspberrypi0-2w-64" ]]; then
        echo "MY_MACHINE: ${MY_MACHINE}"
        if ! grep -q "IMAGE_FSTYPES += \"wic wic.bmap\""  ${LOCAL_CONF_PATH}; then
            echo "IMAGE_FSTYPES += \"wic wic.bmap\"" >> ${LOCAL_CONF_PATH}
        fi
    fi

    if ! grep -q "ENABLE_UART = \"1\""  ${LOCAL_CONF_PATH}; then
        echo "ENABLE_UART = \"1\"" >> ${LOCAL_CONF_PATH}
    fi
}

function build_image()
{
    echo "--- $FUNCNAME ---"
    echo "Build core-image-minimal..."
    #bitbake core-image-base
    bitbake core-image-minimal
}

usage()
{
    echo "${FUNCNAME}"
    echo "======================================"
    echo "Select MACHINE: "
    echo "rpi4          : raspberrypi4"
    echo "rpi4-lkp      : raspberrypi4 lkp"
    echo "rpi0-2w       : raspberrypi0 2w"
    echo "rpi0-2w-lkp   : raspberrypi0 2w lkp"
    echo "qemu          : qemu"
    echo "qemu-lkp      : qemu lkp"
}

export TOP_DIR=`pwd`

build_machine()
{

    BUILD_DIR_NAME=build_raspi4
    LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
    MACHINE_NAME=raspberrypi4
    LKP_LAYER=0

    case $1 in
        "rpi4")
        BUILD_DIR_NAME=build_raspi4
        LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
        MACHINE_NAME="raspberrypi4"
        ;;
        "rpi4-lkp")
        BUILD_DIR_NAME=build_raspi4
        LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
        MACHINE_NAME="raspberrypi4"
        LKP_LAYER=rpi4-lkp
        ;;
        "rpi0-2w")
        BUILD_DIR_NAME=build_raspi0_2w
        LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
        MACHINE_NAME="raspberrypi0-2w-64"
        ;;
        "rpi0-2w-lkp")
        BUILD_DIR_NAME=build_raspi0_2w
        LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
        MACHINE_NAME="raspberrypi0-2w-64"
        LKP_LAYER=rpi0-2w-lkp
        ;;
        "qemu")
        BUILD_DIR_NAME=build_qemuarm
        LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
        MACHINE_NAME="qemuarm64"
        ;;
        "qemu-lkp")
        BUILD_DIR_NAME=build_qemuarm
        LOCAL_CONF_PATH=${TOP_DIR}/${BUILD_DIR_NAME}/conf/local.conf
        MACHINE_NAME="qemuarm64"
        LKP_LAYER=qemu-lkp
        ;;
        *)
        echo "invalid machine option"
        ;;
    esac
    
    echo "---- CHECK ----"
    echo "BUILD_DIR_NAME : ${BUILD_DIR_NAME}"
    echo "LOCAL_CONF_PATH: ${LOCAL_CONF_PATH}"
    echo "MACHINE_NAME   : ${MACHINE_NAME}"
    echo "-----------------"

    get_layers
    setup_layers $TOP_DIR/${BUILD_DIR_NAME} ${LKP_LAYER}
    configure_build ${LOCAL_CONF_PATH} ${MACHINE_NAME}
    build_image

}

if [ $# -gt 0 ]; then
    build_machine $@
else
    echo "Please type options."
    usage
fi

