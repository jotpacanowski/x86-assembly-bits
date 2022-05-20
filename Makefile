inputs  = $(wildcard *.asm)
objects = $(patsubst %.asm,%.o,$(inputs))
outputs = $(patsubst %.asm,%,$(inputs))

all: $(outputs)

clean:
	$(RM) $(objects) $(outputs)

%.o: %.asm
	nasm -f elf64 $<

%: %.o
	cc -o $@ $^

# https://makefiletutorial.com/

test-hello: ./00_hello_world
	@echo -e "\x1b[42;37;1m   Testing hello world \x1b[0m"
	echo '1 1.75' | ./00_hello_world

test-strcpy: ./01_strcpy
	@echo -e "\x1b[42;37;1m   Testing string copy \x1b[0m"
	echo 'String-copy reads only first word...' | ./01_strcpy
	test `echo asdf | ./01_strcpy | grep --count asdf` -eq 2

test-bubble: ./02_bubble_sort
	@echo -e "\x1b[42;37;1m   Testing bubble sort \x1b[0m"
# Test empty file input, program exits with code 1
	echo '' | ./02_bubble_sort || exit 0
# Test single number
	echo '999888999' | ./02_bubble_sort
	echo '4003002001' | ./02_bubble_sort

	echo '4 3 2 -1' | ./02_bubble_sort
	python -c "print(*range(100,0,-1), sep=' ')" | ./02_bubble_sort

test-sqrt: ./03_sqrt
	@echo -e "\x1b[42;37;1m   Testing square root \x1b[0m"
	echo '1.0' | ./03_sqrt

test-exp4: ./04_exp
	@echo -e "\x1b[42;37;1m   Testing e^x \x1b[0m"
	@echo '0 11' | ./04_exp | grep '1.0'
	@echo '1 20' | ./04_exp | grep '2.7182'
	echo '2 20' | ./04_exp

test-exp5: ./05_exp_simd
	@echo -e "\x1b[42;37;1m   Testing e^x (SIMD version) \x1b[0m"
	@echo 'This version computes both e^x and e^(x+1) at the same time.'
	@echo '0 20' | ./05_exp_simd
	@echo '2 20' | ./05_exp_simd
	@echo '-1 20' | ./05_exp_simd

test-exp: test-exp4 test-exp5

tests: test-hello \
	test-strcpy \
	test-bubble \
	test-sqrt \
	test-exp
	@echo -e "\n  \x1b[40;32;1m OK \x1b[0m\n"
