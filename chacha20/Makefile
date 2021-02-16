LDSCRIPT   = ../libopencm3/lib/stm32/f4/stm32f405x6.ld
LIBNAME    = opencm3_stm32f4
ARCH_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
DEFINES    = -DSTM32F4
OBJS       = stm32f4_wrapper.o

all: chacha20test.bin \
		 chacha20speed.bin

chacha20test.elf: quarterround.s load_littleendian.s fullround.s load_test.s chacha20.o chacha20.h test.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ quarterround.s load_littleendian.s fullround.s load_test.s test.o chacha20.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)

chacha20speed.elf: quarterround.s load_littleendian.s fullround.s load_test.s chacha20.o chacha20.h speed.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ quarterround.s load_littleendian.s fullround.s load_test.s speed.o chacha20.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)


include ../common/make.mk


