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
