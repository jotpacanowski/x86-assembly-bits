bits    64
default rel
extern  printf
extern  scanf
global  main

section .text
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	and	rsp, -16
	; The stack will still be aligned to 16 bytes,
	; because the call instruction will push rip
	push	rbp
	call my_main

	pop	rsp
	leave	; TOS-> old rbp
	ret
