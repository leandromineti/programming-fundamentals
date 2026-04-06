; print_uint64 -- print a 64-bit unsigned integer to stdout
;
; Input:  rdi = 64-bit unsigned integer to print
; Output: integer printed to stdout as decimal, followed by newline
; Clobbers: rax, rcx, rdx, rsi, rdi, r8, r11 (syscall clobbers rcx, r11)
;
; Implementation: div-loop approach
;   1. Allocate a 21-byte buffer on the stack (20 digits max for UINT64_MAX + newline)
;   2. Place newline at the end of the buffer
;   3. Repeatedly divide rdi by 10, convert remainder to ASCII ('0'+rem), store backwards
;   4. Special case: if input is 0, output "0\n"
;   5. Call sys_write (rax=1, rdi=1, rsi=buffer_start, rdx=length)
;   6. Return via ret
;
; Calling convention: System V AMD64 ABI
;   Argument passed in rdi (first integer argument register)
;   Caller must save rdi if needed -- this routine clobbers it

section .text

global print_uint64

print_uint64:
    ; Save the value we need to convert
    ; rdi = the number to print

    ; Allocate 21-byte buffer on the stack
    ; [rsp-21 .. rsp-1] = digit buffer, [rsp-1] = newline
    sub     rsp, 24             ; align stack and allocate space (24 = 21 rounded up to 8-byte boundary + 8 for alignment)

    ; Set up pointer to end of buffer (we fill backwards)
    lea     r8, [rsp+20]        ; r8 = pointer to last byte of 21-byte buffer

    ; Place newline at end of buffer
    mov     byte [r8], 0x0a     ; newline byte

    ; Move pointer one position left (first digit position)
    dec     r8

    ; Handle special case: if rdi == 0, output "0\n"
    test    rdi, rdi
    jnz     .convert_loop

    ; rdi is 0: store '0' and jump to print
    mov     byte [r8], '0'
    jmp     .do_print

.convert_loop:
    ; Loop: divide rdi by 10, get remainder, convert to ASCII
    ; Use rax for division (div instruction uses rax:rdx)
    mov     rax, rdi            ; rax = current value
    xor     rdx, rdx            ; rdx:rax = zero-extended value for div
    mov     rcx, 10
    div     rcx                 ; rax = quotient, rdx = remainder (0-9)

    ; Convert remainder to ASCII digit
    add     dl, '0'             ; dl = ASCII digit character
    mov     [r8], dl            ; store digit at current position

    ; Move rdi to quotient for next iteration
    mov     rdi, rax

    ; Move buffer pointer one position left
    dec     r8

    ; Continue if quotient is non-zero
    test    rdi, rdi
    jnz     .convert_loop

    ; Fall through to print

.do_print:
    ; r8 now points to the first digit character (or the '0' for zero case)
    ; after dec, r8 is one before the first digit, so increment to get start
    inc     r8                  ; r8 = pointer to first digit

    ; Calculate length: (rsp+21) - r8 = number of bytes to write
    lea     rsi, [rsp+21]       ; rsi = one past end of buffer
    sub     rsi, r8             ; rsi = length... wait, need pointer not length

    ; Correct: rsi = start pointer, rdx = length
    mov     rsi, r8             ; rsi = pointer to first digit
    lea     rdx, [rsp+21]       ; rdx = one past end (after newline)
    sub     rdx, r8             ; rdx = number of bytes (digits + newline)

    ; sys_write(fd=1, buf=rsi, count=rdx)
    mov     rax, 1              ; syscall number: sys_write
    mov     rdi, 1              ; fd: stdout
    syscall                     ; write digits+newline to stdout

    ; Restore stack
    add     rsp, 24

    ret
