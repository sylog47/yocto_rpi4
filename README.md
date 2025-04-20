# yocto_rpi4
## docker
[docker install & run](./docker/README.md)

## build qemu and run
### build
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