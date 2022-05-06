inputs  = $(wildcard *.asm)
objects = $(patsubst %.asm,%.o,$(inputs))
outputs = $(patsubst %.asm,%,$(inputs))

all: $(outputs)

clean:
	$(RM) $(objects) $(outputs)

# https://makefiletutorial.com/#static-pattern-rules
# All *.o files depend on the include file.
# See also: `nasm -M` option
$(objects): %.o: _common.inc

%.o: %.asm
	nasm -f elf64 $<

%: %.o
	cc -o $@ $^
