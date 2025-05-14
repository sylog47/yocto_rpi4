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