# Makefile for MemTest86+
#
# Author:		Chris Brady
# Created:		January 1, 1996


#
# Path for the floppy disk device
#
FDISK=/dev/fd0

AS=as -32
CC=gcc

CFLAGS= -Wall -march=i486 -m32 -O1 -fomit-frame-pointer -fno-builtin \
	-ffreestanding -fPIC $(SMP_FL) -fno-stack-protector 

LDFLAGS= -m elf_i386
	
OBJS= head.o reloc.o main.o test.o init.o lib.o patn.o screen_buffer.o \
      config.o cpuid.o linuxbios.o pci.o memsize.o spd.o error.o dmi.o controller.o \
      smp.o vmem.o random.o
      

all: clean memetest.bin memetest 

# Link it statically once so I know I don't have undefined
# symbols and then link it dynamically so I have full
# relocation information
memetest_shared: $(OBJS) memetest_shared.lds Makefile
	$(LD) --warn-constructors --warn-common -static -T memetest_shared.lds $(LDFLAGS) \
	 -o $@ $(OBJS) && \
	$(LD) -shared -Bsymbolic -T memetest_shared.lds $(LDFLAGS) -o $@ $(OBJS)

memetest_shared.bin: memetest_shared
	objcopy -O binary $< memetest_shared.bin

memetest: memetest_shared.bin memetest.lds
	$(LD) -s -T memetest.lds -b binary memetest_shared.bin -o $@

head.s: head.S config.h defs.h test.h
	$(CC) -E -traditional $< -o $@

bootsect.s: bootsect.S config.h defs.h
	$(CC) -E -traditional $< -o $@

setup.s: setup.S config.h defs.h
	$(CC) -E -traditional $< -o $@

memetest.bin: memetest_shared.bin bootsect.o setup.o memetest.bin.lds
	$(LD) -T memetest.bin.lds bootsect.o setup.o -b binary \
	memetest_shared.bin -o memetest.bin

reloc.o: reloc.c
	$(CC) -c $(CFLAGS) -fno-strict-aliasing reloc.c

test.o: test.c
	$(CC) -c -Wall -march=i486 -m32 -O0 -fomit-frame-pointer -fno-builtin -ffreestanding test.c

random.o: random.c
	$(CC) -c -Wall -march=i486 -m32 -O3 -fomit-frame-pointer -fno-builtin -ffreestanding random.c
	
# rule for build number generation  
build_number:
	sh make_buildnum.sh  

clean:
	rm -f *.o *.s *.iso memetest.bin memetest memetest_shared \
		memetest_shared.bin memetest.iso

iso:
	make all
	./makeiso.sh

install: all
	install -D memetest.bin $(DESTDIR)/boot/memetest.bin

install-precomp:
	dd <precomp.bin >$(FDISK) bs=8192
	
dos: all
	cat mt86+_loader memetest.bin > memetest.exe
