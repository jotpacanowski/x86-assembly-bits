%include "_common.inc"

section .data
	prompt_float:
	db 'Enter a positive floating-point number: ', 0
	fmt_scan	db '%lf', 0
	fmt_print	db '%lf', 10, 0
	fmt_debug	db 'end = %lf', 10, 0
	fmt_loop	db 'sqrt(%f) = %f', 10, 0

section .bss
	end	resq 1

section .text
my_main:
	lea	rdi, [prompt_float]
	mov	al, 0
	call	printf wrt ..plt

	lea	rdi, [fmt_scan]
	lea	rsi, [end]
	mov	al, 0
	call	scanf wrt ..plt

	cmp	rax, 1
	jnz	.end_err

	movlpd	xmm0, [end]
	lea	rdi, [fmt_debug]
	mov	al, 1
	call	printf wrt ..plt

; --------------------------- LOOP
	movlpd	xmm7, [end]
	mov	rax, __?float64?__(0.125)
	movq	xmm6, rax
	xor	rax, rax
	movq	xmm5, rax  ; loop counter := 0
	;int3
.main_loop:
	movsd	xmm0, xmm5

	lea	rdi, [fmt_loop]
	sqrtsd	xmm1, xmm0
	mov	al, 2
	call	printf wrt ..plt

	addsd	xmm5, xmm6
	comisd	xmm5, xmm7
; COMISD sets CF if xmm5 < xmm7
	jbe	.main_loop

; ---------------------------
.end_err:
	xor	rax, rax
	inc	rax
.end:
	ret
