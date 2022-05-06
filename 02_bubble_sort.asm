bits    64
default rel
extern  printf
extern  scanf
global  main

section .data
	fmt_scan	db '%d', 0
	fmt_print	db '%d ', 0
	fmt_LF		db 10, 0
	fmt_debug	db 'Read %u numbers.', 10, 0

section .bss
	n	resd 1     ; int n;
	array	resd 100   ; int array[100];

section .text
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	and	rsp, -16  ; align the stack (important)
	push	rbp
	push	rbp       ; still aligned to 16 bytes

; --------------------------- ARRAY READING
	lea	r13, [array]
.read_arr:
	lea	rdi, [fmt_scan]
	;lea	rsi, [array+0]
	mov	rsi, r13
	mov	rax, 0
	call	scanf wrt ..plt

	inc	dword [n]
	add	r13, 4
	cmp	rax, 1
	jz	.read_arr
	dec	dword [n]
	; TODO: check n > 100

.read_end:
	mov	esi, dword [n]
	lea	rdi, [fmt_debug]
	mov	rax, 0
	call	printf wrt ..plt

	mov	r12d, dword [n]  ; ecx + loop ??
	lea	r13, [array]
	call	print_n_ints

; --------------------------- BUBBLE SORT array[0..n]
	nop ; TODO

; ---------------------------
	mov	r12d, dword [n]  ; ecx + loop ??
	lea	r13, [array]
	call	print_n_ints

	pop	rsp  ; TOS-> unaligned rsp twice
	pop	rsp
	xor	rax, rax
	leave	; TOS-> old rbp
	ret	; TOS-> old rip

; ---------------------------
print_n_ints:
	; r12d - count, r13 - pointer
.print_loop:
	mov	rsi, [r13]
	lea	rdi, [fmt_print]
	mov	al, 0
	call	printf wrt ..plt

	add	r13, 4  ; sizeof int
	dec	r12
	jnz	.print_loop
.return:
	lea	rdi, [fmt_LF]
	xor	rax, rax
	call	printf wrt ..plt
	ret
