bits    64
default rel
extern  printf
extern  scanf
global  main

;extern stdin
;extern fgets

section .data
	fmt_scan	db '%1023s', 0
	;fmt_scanln	db ' %1023[^\n]', 0
	fmt_print	db '%s', 10, 0
	fmt_debug_inp	db 'Input: %s', 10, 0

section .bss
	input  resb 1024
	output resb 1024

section .text
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	and	rsp, -16  ; align the stack (important)
	push	rbp
	push	rbp       ; still aligned to 16 bytes

	;lea	rdi, [input]
	;mov	rsi, 1023
	;mov	rdx, [stdin]
	;call	fgets wrt ..plt

	lea	rdi, [fmt_scan]
	lea	rsi, [input]
	mov	rax, 0
	call	scanf wrt ..plt

	lea	rsi, [input]
	lea	rdi, [fmt_debug_inp]
	mov	al, 0
	call	printf wrt ..plt

; --------------------------- strcpy() src to dst
	lea	rsi, [input]
	lea	rdi, [output]
	cld	; increment rsi+rdi
.strcpy_L:
	mov	al, [rsi]
	movsb
	test	al, al
	jnz	.strcpy_L

; ---------------------------
	lea	rsi, [output]
	lea	rdi, [fmt_print]
	mov	al, 0
	call	printf wrt ..plt

	xor	rax, rax
	;add	rsp, 16
	pop	rsp  ; TOS-> unaligned rsp twice
	pop	rsp
	leave	; TOS-> old rbp
	ret	; TOS-> old rip
