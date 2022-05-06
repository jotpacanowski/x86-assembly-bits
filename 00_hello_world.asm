bits    64
default rel
extern  printf
extern  scanf

section .data
	fmt_hello	db 'Hello world!', 0xA, 0
	fmt_int		db '%d', 0
	fmt_int_lf	db '%d', 10, 0
	fmt_float	db '%lf', 0
	fmt_float_lf	db '%lf', 10, 0

section .bss
	intarr resd 4
align 16
	dblarr resq 4

section .text
global  main
main:
	sub	rsp, 16

	call main_hello
	call main_int_echo
	call main_float_echo

	add     rsp, 16
	xor     rax, rax
	ret

main_hello:
	lea     rdi, [fmt_hello]
	mov     al, 0
	call    printf wrt ..plt
	ret

main_int_echo:
	push rax
	mov	[rsp], dword 0x00203e69      ; 'i> ' 3e,3f
	lea	rdi, [rsp]
	mov	al, 0
	call printf wrt ..plt
	pop	rax
	lea     rsi, [intarr+0]
	lea	rdi, [fmt_int]
	mov	al, 0
	call	scanf wrt ..plt
	push	rax
	mov	[rsp], dword 0x000a6425   ; "%d\n"
	mov	rsi, [intarr+0]
	mov	rdi, rsp
	mov	al, 0
	call	printf wrt ..plt
	pop	rax
	ret

main_float_echo:
	push	rax
	mov	[rsp], dword 0x00203e66
	lea	rdi, [rsp]
	mov	al, 0
	call	printf wrt ..plt
	pop	rax

	lea	rsi, [dblarr+0]
	lea	rdi, [fmt_float]
	mov	al, 0
	call	scanf wrt ..plt

	movlpd	xmm0, [dblarr]
	lea	rdi, fmt_float_lf
	mov	rax, 1
	call	printf wrt ..plt

	ret
