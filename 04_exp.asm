bits    64
default rel
global  main
extern  printf
extern  scanf

section .data
	str_prompt:	db "Enter x and k: ", 0
	str_scanf:	db "%lf %i", 0
	str_printf:	db "exp(%lf) ~= %lf  (%i steps)", 10, 0

	arg_k:		dd 0
align 16  ; for aligned move instruction
	arg_x:		dq 0.0
	const_one:	dq 1.0

section .text
main:
	sub	rsp, 8
; --------------------------- READING
	lea	rdi, [str_prompt]
	mov	al, 0
	call	printf wrt ..plt

	lea	rdi, [str_scanf]
	lea	rsi, [arg_x]
	lea	rdx, [arg_k]
	call	scanf wrt ..plt

; ---------------------------
	mov	ecx, [arg_k]

	movsd	xmm7, [const_one]
	movsd	xmm0, xmm7        ; result = 1
	movsd	xmm1, xmm7        ; numerator
	movsd	xmm2, xmm7        ; denominator
	movsd	xmm3, [arg_x]
	pxor	xmm6, xmm6        ; i = 0

	test	ecx, ecx
	jz	.loopend
.loop:
	mulsd	xmm1, xmm3        ; num *= x
	addsd	xmm6, xmm7        ; i++
	mulsd	xmm2, xmm6        ; denom *= i
	movsd	xmm4, xmm1        ; buffer = num / denom
	divsd	xmm4, xmm2
	addsd	xmm0, xmm4        ; result += buffer
	loop	.loop
.loopend:
	; xmm0 - result, xmm3 - x
	lea	rdi, [str_printf]
	mov	esi, [arg_k]
	movsd	xmm1, xmm0
	movsd	xmm0, xmm3
	mov	al, 2
	call	printf wrt ..plt

	xor	rax, rax
	add	rsp, 8
	ret
