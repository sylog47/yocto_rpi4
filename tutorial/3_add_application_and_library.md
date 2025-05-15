# Add application and library
Application, Library를 빌드해서 타겟보드에 올리려면  
크로스컴파일을 해서 rootfs에 컴파일된 실행파일과 라이브러리를 옮기는 과정이 필요하다.  
Yocto에서는 이런 일련의 과정을 레시피(*.bb)로 정의하곤 한다.  
  
빌드 중에 윈도우나 안드로이드에서의 라이프사이클에 따라 불리는 콜백함수들처럼 콜백 함수들이 불린다.
이런 콜백함수들로 do_fetch(), do_configure(), do_compile(), do_install(), do_deploy() 등이 있다.  

## Sample library
static library를 컴파일하고 rootfs에 올리는(설치하는) 레시피, Makefile을 작성해보자.
[./meta-lkp/recipes-app/sample-static-lib/files/include/print.h](./meta-lkp/recipes-app/sample-static-lib/files/include/print.h)
~~~C
#ifndef SAMPLE_PRINT_H__
#define SAMPLE_PRINT_H__

void print_hello(void);

#endif
~~~

[./meta-lkp/recipes-app/sample-static-lib/files/src/print.c](./meta-lkp/recipes-app/sample-static-lib/files/src/print.c)
~~~C
#include <stdio.h>
#include "print.h"

void print_hello(void)
{
    printf("%s, %d: \n", __func__, __LINE__);
}
~~~

[./meta-lkp/recipes-app/sample-static-lib/files/include/arith.h](./meta-lkp/recipes-app/sample-static-lib/files/include/arith.h)  
~~~C
#ifndef ARITH_H__
#define ARITH_H__

void print_arith(void);

#endif
~~~

[./meta-lkp/recipes-app/sample-static-lib/files/src/arith.c](./meta-lkp/recipes-app/sample-static-lib/files/src/arith.c)
~~~C
#include <stdio.h>
#include "arith.h"

void print_arith(void)
{
    printf("%s, %d: \n", __func__, __LINE__);
}
~~~
  
[./meta-lkp/recipes-app/sample-static-lib/files/Makefile](./meta-lkp/recipes-app/sample-static-lib/files/Makefile)
~~~bash
TARGET = libmystatic.a
INCLUDE_DIR = ./include
SRC_DIR = ./src

OBJS = ${SRC_DIR}/print.o \
		${SRC_DIR}/arith.o

CFLAGS = -I${INCLUDE_DIR}
CFLAGS += -Wno-pointer-to-int-cast
CFLAGS += -Wno-int-conversion


all: ${TARGET}

#$@ is the name of the target being generated, and $< the first prerequisite (usually a source file).
${TARGET}: ${OBJS}
	${AR} rcs $@ $^

$(addprefix src/, %.o): ${SRC_DIR}/%.c
	${CC} ${LDFLAGS} -c ${CFLAGS} $< -o $@

clean:
	-rm -f ${SRC_DIR}/*.o
	-rm -f ${TARGET}
~~~

이제 이 코드를 빌드해서 rootfs에 올리기 위한 recipe파일을 보자.
 - CHECKSUM을 설정할 수 있는데, 편의상 CLOSED로 바꿔놨다. 나중에 이것도 추가로 정리해보자.
 - SRC_URI: 파일, 디렉토리들 정의
 - B, S glossary: build directory, source directory
 - UNPACKDIR: 회사에서는 Intel Agilex5 SoC를 사용하는데 yocto버전을 최신 버전(styhead)을 사용하고 있다. styhead부터는 UNPACKDIR을 사용하면 source를 중복(build, source)으로 갖고 있지 않고 하나로 갖고 있을 수 있다고 한다.
 - do_compile: compile태스크. 비워놔도 알아서 oe_runmake했다. 나는 재정의한 상태이다.  
 - oe_runmake: yocto 빌드 중에는 make명령보다는 oe_runmake를 사용해야한다.  
 - do_install: do_compile에서 빌드된 라이브러리(libmystatic.a)를 rootfs에 설치하도록 정의했다. 그리고 library사용자가 사용하려면 header파일도 필요하므로 설치했다.
  - D: destination directory
  - libdir: /usr/local/lib 경로
  - includedir: /usr/include 경로
  - bindir: /usr/local/bin 경로
  - PROVIDES: 이 개념이 처음 yocto를 접했을 때 제일 이해가 안갔던 부분이다.  
    다른 패키지(레시피)에서 이 패키지를 의존성(DEPEND)을 가진 것으로 정의해두면,  
    이 패키지가 먼저 빌드된다.  
    (이런 부분은 마음에 든다. 깔끔하고 가독성도 좋다.)  
    이 패키지를 PROVIDE로 추가해주지 않으면 이 라이브러리를 사용하는 패키지를 bitbake하는 데 에러가 발생한다.  
  - RPROVIDES: run provide 실행 시에 제공해준다는 의미이다. 위의 provide는 빌드 의존성을 위해 제공한다는 의미이고 이건 런타임 의존성을 위해 제공해준다는 의미이다.

~~~bash
DESCRIPTION = "Simple hello world static library"
LICENSE = "CLOSED"

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
PROVIDES:${PN} += "sample-static-lib"
RPROVIDES:${PN} += "sample-static-lib"
~~~

## Sample Application
Library를 이용하는 Application을 만들어보자.  
~~~bash
yocto_rpi@sy-desktop:~/kernel$ tree meta-lkp/recipes-app/helloworld/
meta-lkp/recipes-app/helloworld/
├── files
│   ├── include
│   │   └── greet.h
│   ├── Makefile
│   └── src
│       ├── greet.c
│       └── main.c
└── lkp-helloworld_0.1.bb

3 directories, 5 files
yocto_rpi@sy-desktop:~/kernel$ 
~~~

코드는 간단한 인삿말을 출력하는 함수들(greet.c)과 라이브러리 함수를 사용하는 부분인 main.c로 구성되어 있다.  
Makefile을 보자.  
 - TARGET: LKP_HELLOWORLD_TARGET변수를 읽어서 설정하고 있다. 
 이 변수는 lkp-helloworld.bb에서 전달인자로 넘기고 있다. 이어서 나오는 레시피 부분에서 다시 보자.  
 - LKP_HELLOWORLD_INCLUDE_DIR: 이 변수 역시 lkp-helloworld.bb에서 전달인자로 넘기고 있다. 이어서 나오는 레시피 부분에서 다시 보자.  
 - -lmystatic: linking할 라이브러리 명이다.
 - LDFLAGS: yocto 빌드 중에 설정된 기본 LDFLAGS 값이 있다. 여기서 라이브러리 경로(-L/usr/libs)가 설정되기 때문에 여기서는 따로 -L플래그를 설정해주지 않아도 된다.  

~~~bash
TARGET = ${LKP_HELLOWORLD_TARGET}
INCLUDE_DIR = ./include
SRC_DIR = ./src

OBJS = ${SRC_DIR}/main.o \
		${SRC_DIR}/greet.o

CFLAGS = -I${INCLUDE_DIR}
CFLAGS += -I${LKP_HELLOWORLD_INCLUDE_PATH}
CFLAGS += -Wno-pointer-to-int-cast
CFLAGS += -Wno-int-conversion
CSTDFLAG = -std=c99

all: ${TARGET}

#$@ is the name of the target being generated, and $< the first prerequisite (usually a source file).
$(TARGET):$(OBJS)
	@echo "TARGET: ${TARGET}"
	$(CC) ${LDFLAGS} $(CFLAGS) $(CSTDFLAG) -o $@ $^ -lm -lmystatic

$(OBJDIR)/%.o:%.c
	$(CC) ${LDFLAGS} $(CSTDFLAG) $(CFLAGS) $(IFLAGS) -o $@ -c $<


clean:
	-rm -f ${SRC_DIR}/*.o
	-rm -f ${TARGET}

~~~


recipe를 보자.
 - EXTRA_OEMAKE: LKP_HELLOWORLD_TARGET, LKP_HELLOWORLD_INCLUDE_PATH변수를 전달인자로 넘기고 있다. package recipe에서는 이렇게 Makefile에 전달할 수 있다.  
 - do_compile(): do_compile태스크. 컴파일하는 함수인데, 생략해줘도 자동으로 Make를 실행한다. 나는 그냥 재정의했다.  
 - do_install(): 빌드된 실행파일(바이너리)을 rootfs에 설치한다.
 - D: destination directory
 - bindir: bin directory, /usr/local/bin 경로를 의미한다.
 - PN: Package Name을 의미한다. 보통 *.bb파일 명을 의미한다.  
 - FILE:\$\{PN\}: rootfs에 추가할 파일을 추가한다. ${PN}은 Package Name 변수의 값을 의미한다. 즉, package에서 사용하는 파일들을 정의하는 것이다. 이 선언문이 없으면 에러가 발생한다. install태스크에서 설치했는데, 이 선언문이 없으면 에러가 발생한다. 이 변수가 필요 없을 것 같을 수 있다.(install태스크에서 설치하는데 왜?) 하지만 뒤에서 볼 debug패키지를 보면, 이 FILE이라는 것을 사용하면 디버그, 릴리즈용 파일을 분리할 수 있다는 점에서 편리함이 있다.  

~~~bash
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

# If you're compiling the source for yourself, you should not skip the LDFLAGS warning as mentioned and you should add the following line in your Yocto recipe
# https://stackoverflow.com/questions/61473077/didnt-pass-ldflags-ldflags
TARGET_CC_ARCH += "${LDFLAGS}"

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

~~~

