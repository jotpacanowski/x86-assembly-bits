bits    64
default rel
global  main
extern  printf
extern  scanf

section .data
	fmt_scan	db '%d', 0
	fmt_print	db '%d ', 0
	fmt_LF		db 10, 0
	fmt_debug	db 'Read %u numbers.', 10, 0

section .bss
	n	resd 1     ; int n;
	array	resd 100   ; int array[100];
array_end:

section .text
main:
	sub	rsp, 8
; --------------------------- ARRAY READING
	lea	r13, [array]
	lea	r14, [array_end]
.read_arr:
	cmp	r13, r14     ; check n >= 100
	jge	.read_too_many

	lea	rdi, [fmt_scan]
	mov	rsi, r13
	mov	rax, 0
	call	scanf wrt ..plt

	inc	dword [n]
	add	r13, 4
	cmp	rax, 1
	jz	.read_arr
.read_end:                ; If scanf failed... (returned 0 or -1)
	lea	r14, [array+4]
	cmp	r13, r14
	jnz	.read_ok  ; ...and was called only once
	xor	rax, rax  ; Exit with error 1
	inc	rax
	add	rsp, 8
	ret
.read_too_many:
	inc	dword [n]
.read_ok:
	dec	dword [n]
	lea	r14, [array]
	sub	r13, r14
	shr	r13, 2
	;int3
	cmp	r13, 2
	jz	.end

	mov	esi, dword [n]
	lea	rdi, [fmt_debug]
	mov	rax, 0
	call	printf wrt ..plt

	mov	r12d, dword [n]  ; ecx + loop ??
	lea	r13, [array]
	call	print_n_ints

; --------------------------- BUBBLE SORT array[0..n]
	mov	r12d, dword [n]  ; i = n
.bubble_sort_loop:
	mov	ecx, dword [n]   ; j = n-1
	dec	ecx
.inner:
	lea	rsi, [array]
	lea	rsi, [rsi + 4*rcx]
	lea	rdi, [rsi-4]

	mov	eax, dword [rsi] ; array[j]
	mov	edx, dword [rdi] ; array[j-1]
	cmp	eax, edx  ; a[j] < a[j-1]
	jge .no_swap
.swap:
	mov	dword [rsi], edx
	mov	dword [rdi], eax
	;jmp	.after_swap
.no_swap:
.after_swap:
	sub	rsi, 4
	sub	rdi, 4
	;
	loop .inner              ; j -= 1
	;
	dec	r12
	jnz	.bubble_sort_loop

; ---------------------------
.end:
	mov	r12d, dword [n]  ; ecx + loop ??
	lea	r13, [array]
	call	print_n_ints
	xor	rax, rax
	add	rsp, 8
	ret

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
