# build image and configuration

## terminology
Layer, meta data, task, 
variable, operators.

## build
In scarthgap branch, there are latest commits.
It seems that raspberrypi is officially supported in Yocto.
(https://git.yoctoproject.org/meta-raspberrypi/?h=scarthgap)


### clone, setup environment, layers
~~~bash
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
    echo "BUILD_DIR: ${BUILD_DIR}"
    source poky/oe-init-build-env ${BUILD_DIR}


    bitbake-layers show-layers

    echo "Add meta-raspberrypi layer..."
    bitbake-layers add-layer ../meta-raspberrypi

    echo "Current Layers:"
    bitbake-layers show-layers
}

get_layers
setup_layers build_raspi4
~~~

## configurations
 - parallel build
 - save disk space
 - sstate
