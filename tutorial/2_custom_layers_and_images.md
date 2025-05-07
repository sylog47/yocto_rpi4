# Create custom layer
## init env
source명령어를 이용해서 환경변수 들을 설정한다.  
~~~bash
yocto_rpi@sy-desktop:~/kernel$ source poky/oe-init-build-env build_qemuarm/
This is the default build configuration for the Poky reference distribution.

### Shell environment set up for builds. ###

You can now run 'bitbake <target>'

Common targets are:
    core-image-minimal
    core-image-full-cmdline
    core-image-sato
    core-image-weston
    meta-toolchain
    meta-ide-support

You can also run generated qemu images with a command like 'runqemu qemux86-64'.

Other commonly useful commands are:
 - 'devtool' and 'recipetool' handle common recipe tasks
 - 'bitbake-layers' handles common layer tasks
 - 'oe-pkgdata-util' handles common target package tasks
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ 
~~~
source command가 뭔지 모른다면, 아래 링크들을 참고하면 된다.  
[how-to-use-source-command-in-shell-script](https://superuser.com/questions/1218586/how-to-use-source-command-in-shell-script)  
[source-command-in-linux-with-examples](https://www.geeksforgeeks.org/source-command-in-linux-with-examples/)  

여기서는 빌드 디렉토리들을 환경변수로 설정해주고, bitbake-layers실행파일을 PATH 환경변수에 추가한다.  
oe-init-build-env스크립트를 잠깐 살펴보자.  
oe-buildenv-internal스크립트를 실행하고 있다.(.은 source 커맨드를 의미한다.)  
~~~bash
# poky/oe-init-build-env
if [ -z "$OEROOT" ]; then
    OEROOT=$(dirname "$THIS_SCRIPT")
    OEROOT=$(readlink -f "$OEROOT")
fi
unset THIS_SCRIPT

export OEROOT
. "$OEROOT"/scripts/oe-buildenv-internal &&
    TEMPLATECONF="$TEMPLATECONF" "$OEROOT"/scripts/oe-setup-builddir || {
    unset OEROOT
    return 1
}
~~~
  
이 스크립트에서 bitbake-layers같은 python script를 PATH 환경변수에 추가해준다.  
[poky/scripts/oe-buildenv-internal](../poky/scripts/oe-buildenv-internal)
~~~bash
## ...
# Add BitBake's library to PYTHONPATH
PYTHONPATH=$BITBAKEDIR/lib:$PYTHONPATH
export PYTHONPATH

# Remove any paths added by sourcing this script before
[ -n "$OE_ADDED_PATHS" ] && PATH=$(echo $PATH | sed -e "s#$OE_ADDED_PATHS##") ||
    PATH=$(echo $PATH | sed -e "s#$OEROOT/scripts:$BITBAKEDIR/bin:##")

# Make sure our paths are at the beginning of $PATH
OE_ADDED_PATHS="$OEROOT/scripts:$BITBAKEDIR/bin:"
PATH="$OE_ADDED_PATHS$PATH"
export OE_ADDED_PATHS
## ...
~~~
  
아래 경로를 보면, 자주 사용하는 bitbake 커맨드들이 python script로 구현되어 있는 것을 볼 수 있다.  
위에서 본 oe-buildenv-internal스크립트는 아래 경로를 PATH환경변수에 추가해서  
파이썬 스크립트를 명령처럼 사용할 수 있게 된다.  
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ ls -al ../poky/bitbake/bin
total 112
drwxr-xr-x 2 yocto_rpi yocto_rpi  4096 May  6 20:09 .
drwxr-xr-x 6 yocto_rpi yocto_rpi  4096 May  6 20:09 ..
-rwxr-xr-x 1 yocto_rpi yocto_rpi  1238 May  6 20:09 bitbake
-rwxr-xr-x 1 yocto_rpi yocto_rpi  8189 May  6 20:09 bitbake-diffsigs
lrwxrwxrwx 1 yocto_rpi yocto_rpi    16 May  6 20:09 bitbake-dumpsig -> bitbake-diffsigs
-rwxr-xr-x 1 yocto_rpi yocto_rpi  2417 May  6 20:09 bitbake-getvar
-rwxr-xr-x 1 yocto_rpi yocto_rpi 14844 May  6 20:09 bitbake-hashclient
-rwxr-xr-x 1 yocto_rpi yocto_rpi  5855 May  6 20:09 bitbake-hashserv
-rwxr-xr-x 1 yocto_rpi yocto_rpi  3540 May  6 20:09 bitbake-layers
-rwxr-xr-x 1 yocto_rpi yocto_rpi  2154 May  6 20:09 bitbake-prserv
-rwxr-xr-x 1 yocto_rpi yocto_rpi  1956 May  6 20:09 bitbake-selftest
-rwxr-xr-x 1 yocto_rpi yocto_rpi  1548 May  6 20:09 bitbake-server
-rwxr-xr-x 1 yocto_rpi yocto_rpi 20519 May  6 20:09 bitbake-worker
-rwxr-xr-x 1 yocto_rpi yocto_rpi  6045 May  6 20:09 git-make-shallow
-rwxr-xr-x 1 yocto_rpi yocto_rpi  9537 May  6 20:09 toaster
-rwxr-xr-x 1 yocto_rpi yocto_rpi  1723 May  6 20:09 toaster-eventreplay
~~~
  
  
## bitbake-layers help command
layer를 생성하기 전에 bitbake-layers 사용법을 확인해보자.  
option과 subcommand를 함께 사용해야하는 것으로 보인다.  
create-layer와 add-layer를 사용하면 될 듯하다.  
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ bitbake-layers -h
NOTE: Starting bitbake server...
usage: bitbake-layers [-d] [-q] [-F] [--color COLOR] [-h] <subcommand> ...

BitBake layers utility

options:
  -d, --debug           Enable debug output
  -q, --quiet           Print only errors
  -F, --force           Force add without recipe parse verification
  --color COLOR         Colorize output (where COLOR is auto, always, never)
  -h, --help            show this help message and exit

subcommands:
  <subcommand>
    layerindex-fetch    Fetches a layer from a layer index along with its dependent layers, and adds them to conf/bblayers.conf.
    layerindex-show-depends
                        Find layer dependencies from layer index.
    add-layer           Add one or more layers to bblayers.conf.
    remove-layer        Remove one or more layers from bblayers.conf.
    flatten             flatten layer configuration into a separate output directory.
    show-layers         show current configured layers.
    show-overlayed      list overlayed recipes (where the same recipe exists in another layer)
    show-recipes        list available recipes, showing the layer they are provided by
    show-appends        list bbappend files and recipe files they apply to
    show-cross-depends  Show dependencies between recipes that cross layer boundaries.
    create-layers-setup
                        Writes out a configuration file and/or a script that replicate the directory structure and revisions of the
                        layers in a current build.
    save-build-conf     Save the currently active build configuration (conf/local.conf, conf/bblayers.conf) as a template into a layer.
    create-layer        Create a basic layer

Use bitbake-layers <subcommand> --help to get help on a specific command
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ 
~~~

## Create new layer
layer를 새로 생성해보자.  
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ bitbake-layers create-layer ../meta-lkp
NOTE: Starting bitbake server...
Add your new layer with 'bitbake-layers add-layer ../meta-lkp'
~~~

layer.conf를 조금 뜯어보자.  
recipes-*만 붙여서 폴더를 만들어서 recipe를 생성해놓으면 마법처럼 레시피가 빌드된다고 생각할 수도 있겠지만,  
여기셔 *.bb, *.bbappend파일들을 추가해주기 때문에 사용이 가능하다.  
[meta-lkp/conf/layer.conf](meta-lkp/conf/layer.conf)  
 - BBFILE_COLLECTIONS에 layer 이름을 추가해준다.  
 - BBFILES에 recipes-*디렉토리 내의 레시피(\*.bb, *.bbappend)파일들을 추가하고 있다.  
 - LAYERDEPENDS_meta-lkp 구문을 보면, core레이어에 의존적이다.  
 (이 레이어를 추가하기 위해서는 core layer가 추가되어 있어야 한다.)  
 - LAYERSERIES_COMPAT_meta: scarthgap 브랜치(버전)를 사용하고 있다.  
~~~bash
# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"

# We have recipes-* directories, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "meta-lkp"
BBFILE_PATTERN_meta-lkp = "^${LAYERDIR}/"
BBFILE_PRIORITY_meta-lkp = "6"

LAYERDEPENDS_meta-lkp = "core"
LAYERSERIES_COMPAT_meta-lkp = "scarthgap"
~~~

## Add new layer
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                                                    priority
========================================================================================================
core                  /home/yocto_rpi/kernel/poky/meta                                        5
yocto                 /home/yocto_rpi/kernel/poky/meta-poky                                   5
yoctobsp              /home/yocto_rpi/kernel/poky/meta-yocto-bsp                              5
raspberrypi           /home/yocto_rpi/kernel/meta-raspberrypi                                 9
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ 
~~~
  
생성한 meta-lkp 레이어를 추가한다.  
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ bitbake-layers add-layer ../meta-lkp/
NOTE: Starting bitbake server...
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ 
~~~
  
layer가 추가됬는지 확인해보자.  
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                                                    priority
========================================================================================================
core                  /home/yocto_rpi/kernel/poky/meta                                        5
yocto                 /home/yocto_rpi/kernel/poky/meta-poky                                   5
yoctobsp              /home/yocto_rpi/kernel/poky/meta-yocto-bsp                              5
raspberrypi           /home/yocto_rpi/kernel/meta-raspberrypi                                 9
meta-lkp              /home/yocto_rpi/kernel/meta-lkp                                         6
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ 
~~~


## Create custom image
custom image를 추가해보자.  
build.sh에서 생성한 이미지는 아래와 같이 core-image-minimal 레시피(*.bb)를 bitbake해서 만들어진다.
~~~bash
yocto_rpi@sy-desktop:~/kernel/build_qemuarm$ find .. -name core-image-minimal*.bb
../poky/meta/recipes-core/images/core-image-minimal-mtdutils.bb
../poky/meta/recipes-core/images/core-image-minimal-initramfs.bb
../poky/meta/recipes-core/images/core-image-minimal.bb
../poky/meta/recipes-core/images/core-image-minimal-dev.bb
~~~

### core-image-minimal.bb
core-image-minimal.bb파일을 열어보자.
 - IMAGE_INSTALL변수에는 추가할 패키지들을 추가해줄 수 있다.  
 - packagegroup-core-boot도 레시피인데, 이름 그대로 패키지들의 그룹이다.  
   이렇게 동일한 성격의 package들을 그룹으로 만들어놓으면 유지보수가 편해진다.  
 - core-image를 inherit하는 구문이 있다.  
   이 구문은 core-image.bbclass를 상속한다는 의미이다.  
  [../poky/meta/classes-recipe/core-image.bbclass](../poky/meta/classes-recipe/core-image.bbclass)

 - IMAGE_ROOTFS_EXTRA_SPACE:
    yocto 공식 매뉴얼 문서에 설명이 잘 나와 있다.  
    https://docs.yoctoproject.org/2.0/ref-manual/ref-manual.html#var-IMAGE_ROOTFS_EXTRA_SPACE
      
    ~~~
    이미지에 생성되는 추가 여유 디스크 공간을 KB 단위로 정의합니다. 기본적으로 이 변수는 "0"으로 설정됩니다. 이 여유 디스크 공간은 빌드 시스템이 IMAGE_ROOTFS_SIZE에 설명된 대로 이미지 크기를 결정한 후 이미지에 추가됩니다.

    이 변수는 이미지가 설치되고 실행된 후 장치에 특정 양의 여유 디스크 공간이 있는지 확인하려는 경우 특히 유용합니다. 예를 들어, 5GB의 여유 디스크 공간을 확보하려면 다음과 같이 변수를 설정합니다.
    ~~~
    bb.utils.contains함수를 사용하고 있다.  
    systemd가 DISTRO_FEATURES의 부분집합이면 "+ 4096"을 리턴해서  
    IMAGE_ROOTFS_EXTRA_SPACE에는 " + 4096" 이 덧붙여진다(append).
    systemd를 사용 중이면 추가 공간을 확보하는 듯하다.  

 - bb.utils.contains:  
   이 함수는 두 번째 인수가 첫 번째 인수의 부분 집합이면 세 번째 인수를 반환하고, 그렇지 않으면 네 번째 인수를 반환합니다.
   https://embeddedguruji.blogspot.com/2019/03/bbutilscontains-yocto.html
    
 - core-image.bbclass
 이미지에 추가되는 패키지들이 정의되어 있다. 나중에 필요 없는 것은 제거할 수도 있다.  
 예전에 회사 제품이 NOR Flash를 사용해서 용량이 적어서 rootfs를 줄이기 위해 기본 패키지를 줄여야 하기도 했었다.  
 [../poky/meta/classes-recipe/core-image.bbclass](../poky/meta/classes-recipe/core-image.bbclass)
~~~bash
SUMMARY = "A small image just capable of allowing a device to boot."

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"
~~~

다시 주제로 돌아와서 단순한 접근으로, core-image-minimal을 복사해서 커스텀 이미지를 만들어보자.  
~~~bash
yocto_rpi@sy-desktop:~/kernel$ cd meta-lkp/
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ tree .
.
├── conf
│   └── layer.conf
├── COPYING.MIT
├── README
└── recipes-example
    └── example
        └── example_0.1.bb

3 directories, 4 files
yocto_rpi@sy-desktop:~/kernel/meta-lkp$
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ mkdir -p recipes-core/images
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ cp -vrf ../poky/meta/recipes-core/images/* recipes-core/images/
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ tree .
.
├── conf
│   └── layer.conf
├── COPYING.MIT
├── README
├── recipes-core
│   └── images
│       ├── build-appliance-image
│       │   ├── README_VirtualBox_Guest_Additions.txt
│       │   ├── README_VirtualBox_Toaster.txt
│       │   ├── Yocto_Build_Appliance.vmx
│       │   └── Yocto_Build_Appliance.vmxf
│       ├── build-appliance-image_15.0.0.bb
│       ├── core-image-base.bb
│       ├── core-image-initramfs-boot.bb
│       ├── core-image-minimal.bb
│       ├── core-image-minimal-dev.bb
│       ├── core-image-minimal-initramfs.bb
│       ├── core-image-minimal-mtdutils.bb
│       ├── core-image-ptest-all.bb
│       ├── core-image-ptest.bb
│       ├── core-image-ptest-fast.bb
│       └── core-image-tiny-initramfs.bb
└── recipes-example
    └── example
        └── example_0.1.bb

6 directories, 19 files
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ 

yocto_rpi@sy-desktop:~/kernel/meta-lkp$ cp recipes-core/images/core-image-minimal.bb recipes-core/images/lkp-image.bb
~~~

실행해보자.  
~~~bash
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ bitbake lkp-image
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ ll ../build_qemuarm/tmp/deploy/images/qemuarm64/
yocto_rpi@sy-desktop:~/kernel/meta-lkp$ runqemu qemuarm64 nographic
~~~
