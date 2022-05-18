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

section .text
main:
	sub	rsp, 8
; --------------------------- READING
	lea	rdi, [str_prompt]
	mov	al, 0
	call	printf wrt ..plt

	lea	rdi, [str_scanf]
	lea	rsi, [arg_x+0]
	lea	rdx, [arg_k]
	call	scanf wrt ..plt

; ---------------------------
	mov	ecx, [arg_k]

; Using a trick from chapter 13.8 (table 13.10) of
; https://www.agner.org/optimize/optimizing_assembly.pdf
; double-precision 1.0 in hex is 3f f0 00 ... 00
	pcmpeqw	xmm7, xmm7   ; all 1's
	psllq	xmm7, 54     ; Set mantissa to zero
	psrlq	xmm7, 2      ; Shift to set sign and exponent correctly
	; xmm7 = {1.0, 1.0}

	movdqa	xmm0, xmm7        ; result = 1
	movdqa	xmm1, xmm7        ; numerator
	movdqa	xmm2, xmm7        ; denominator
	movsd	xmm3, [arg_x]
	addsd	xmm3, xmm7
	movlhps	xmm3, xmm3        ; xmm3[0] = xmm3[1] = x + 1
	movlpd	xmm3, [arg_x]     ; xmm3[0] = x
	pxor	xmm6, xmm6        ; i = 0

	test	ecx, ecx
	jz	.loopend
.loop:
	mulpd	xmm1, xmm3        ; num *= x
	addpd	xmm6, xmm7        ; i++
	mulpd	xmm2, xmm6        ; denom *= i
	movdqa	xmm4, xmm1        ; buffer = num / denom
	divpd	xmm4, xmm2
	addpd	xmm0, xmm4        ; result += buffer
	loop	.loop
.loopend:
	sub	rsp, 32
	movapd	[rsp+16], xmm0    ; Save result
	movapd	[rsp], xmm3       ; Save x

	movdqa	xmm1, xmm0
	movdqa	xmm0, xmm3
	lea	rdi, [str_printf]
	mov	esi, [arg_k]
	mov	al, 2
	call	printf wrt ..plt

; PSHUFD - shuffle packed doublewords (4-byte / 32-bit integers)
; Despite that "integer" in the description, this instruction
; can be used to move floating-point values.
; Reference link: https://www.felixcloutier.com/x86/pshufd#operation
; 0b1110 = move (3rd, 4th) integer into the 64-bit part of the register
	movapd	xmm0, [rsp]
	pshufd	xmm0, xmm0, 0b11101110
	movapd	xmm1, [rsp+16]
	pshufd	xmm1, xmm1, 0b11101110

	lea	rdi, [str_printf]
	mov	esi, [arg_k]
	mov	al, 2
	call	printf wrt ..plt

	add	rsp, 32

	xor	rax, rax
	add	rsp, 8
	ret
