# bfx86 makefile, don't touch if you don't know what you are doing!
OUTPUTNAME := bfx86
ASMDEBUG := -g dwarf2
LDDEBUG := -g

# Objects to be linked
OBJS := bfx86.o
SOURCES := bfx86.asm

# Assembler to use
ASM := yasm
ASMFLAGS := -f elf64

# Linker to use
LD := ld
LDFLAGS := -o $(OUTPUTNAME)

all: $(OUTPUTNAME)

$(OUTPUTNAME): $(OBJS)
	$(LD) $(LDDEBUG) $(LDFLAGS) $(OBJS)

$(OBJS): $(SOURCES)
	$(ASM) $(ASMFLAGS) $(ASMDEBUG) $(SOURCES)

clean:
	rm $(OBJS)
	rm $(OUTPUTNAME)
