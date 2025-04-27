# yocto_rpi4
## docker
[docker install & run](./docker/README.md)

## build qemu and run
### MACHIN설정
아래 machine.conf파일들의 이름들이 Layer내에서 지원되는 머신들이다.  
raspberrypi4 는 raspberrypi4-64 또는 raspberrypi4로 설정하면 된다.  
raspberrypi0 2W는 raspberrypi0-2w 또는 raspberrypi0으로 설정하면 된다.  
MACHINE변수를 설정하는 부분은 build.sh를 참고.  
~~~bash
sooley@sooley-LEGION:~/Work/yocto_rpi4$ ls -al meta-raspberrypi/conf/machine
total 72
drwxr-xr-x 3 sooley sooley 4096  1월 11 14:01 .
drwxr-xr-x 3 sooley sooley 4096  1월 11 14:01 ..
drwxr-xr-x 2 sooley sooley 4096  1월 11 14:01 include
-rw-r--r-- 1 sooley sooley  461  1월 11 14:01 raspberrypi0-2w-64.conf
-rw-r--r-- 1 sooley sooley  382  1월 11 14:01 raspberrypi0-2w.conf
-rw-r--r-- 1 sooley sooley  291  1월 11 14:01 raspberrypi0.conf
-rw-r--r-- 1 sooley sooley  585  1월 11 14:01 raspberrypi0-wifi.conf
-rw-r--r-- 1 sooley sooley  387  1월 11 14:01 raspberrypi2.conf
-rw-r--r-- 1 sooley sooley 1096  1월 11 14:01 raspberrypi3-64.conf
-rw-r--r-- 1 sooley sooley  644  1월 11 14:01 raspberrypi3.conf
-rw-r--r-- 1 sooley sooley 1127  1월 11 14:01 raspberrypi4-64.conf
-rw-r--r-- 1 sooley sooley  690  1월 11 14:01 raspberrypi4.conf
-rw-r--r-- 1 sooley sooley  962  1월 11 14:01 raspberrypi5.conf
-rw-r--r-- 1 sooley sooley 1417  1월 11 14:01 raspberrypi-armv7.conf
-rw-r--r-- 1 sooley sooley 1408  1월 11 14:01 raspberrypi-armv8.conf
-rw-r--r-- 1 sooley sooley  413  1월 11 14:01 raspberrypi-cm3.conf
-rw-r--r-- 1 sooley sooley  235  1월 11 14:01 raspberrypi-cm.conf
-rw-r--r-- 1 sooley sooley  398  1월 11 14:01 raspberrypi.conf
sooley@sooley-LEGION:~/Work/yocto_rpi4$ 
~~~

#### build.sh 중 local.conf설정 관련 내용
 - DL_DIR, SSTATE_DIR: build.sh를 참고  
 - rm_work: 빌드 시에 사용하는 저장용량을 줄이기 위해 rm_work클래스를 상속받았다.  
 - rm_work exclude: kernel, u-boot 등은 지우지 않도록 할 수있으나 지금은 임시로 disable해놓았다.  
 - 병렬 빌드: 빌드 속도를 빠르게 하기 위해 PARALLEL_MAKE, BB_NUMBER_THREADS 설정도 추가했다.  
 - booting log: 부팅 로그를 보기위해 ENABLE_UART설정도 추가되어 있다.  

## build qemuarm and run
~~~bash
./build.sh qemu
~~~

### qemu run
~~~bash
$ source poky/oe-init-build-env build_qemuarm/
$ runqemu qemuarm64 nographic
~~~

root로 로그인  
종료할 때는 Ctrl+A+X  
[arm qemu build document](https://learn.arm.com/learning-paths/embedded-and-microcontrollers/yocto_qemu/yocto_build/)

## build rpi4 and run
### build
~~~bash
./build.sh rpi4
~~~

### run
#### sdcard image flash
sdcard image (.wic) 파일을 확인, 빌드 서버에서 가져온다.  
 - raspberrypi4
~~~bash
$ ll build_raspi4/tmp/deploy/images/raspberrypi4/core-image-minimal*.wic
$ realpath build_raspi4/tmp/deploy/images/raspberrypi0-2w-64/core-image-minimal*.wic
$ scp <ssh address>:<img path> ./
~~~

 - raspberrypi0 2w
~~~bash
$ ll build_raspi0_2w/tmp/deploy/images/raspberrypi0-2w-64/core-image-minimal*.wic
$ realpath build_raspi0_2w/tmp/deploy/images/raspberrypi0-2w-64/core-image-minimal*.wic
$ scp <ssh address>:<img path> ./
~~~

balena etcher를 다운받아서 굽는다.  
sdcard를 라즈베리파이에 꽂고 전원을 키면 부팅로그가 나온다.  
