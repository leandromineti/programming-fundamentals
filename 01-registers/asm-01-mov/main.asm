; asm-01-mov: Register Sizes and the MOV Instruction
;
; This program demonstrates the mov instruction across all four register widths
; in x86-64: rax (64-bit), eax (32-bit), ax (16-bit), al (8-bit).
;
; Key insight -- the zero-extension rule:
;   Writing to eax ALWAYS clears the upper 32 bits of rax. Writing to ax or al does NOT.
;
; No libc dependency -- all output via Linux syscalls (sys_write=1, sys_exit=60).

section .data
    msg_header  db "--- mov: register sizes ---", 10
    msg_header_len equ $ - msg_header

    msg_64bit   db "Loading rax with 64-bit immediate", 10
    msg_64bit_len equ $ - msg_64bit

    msg_32bit   db "Loading eax (clears upper 32 bits of rax)", 10
    msg_32bit_len equ $ - msg_32bit

    msg_16bit   db "Loading ax (preserves upper bits)", 10
    msg_16bit_len equ $ - msg_16bit

    msg_8bit    db "Loading al (preserves upper bits)", 10
    msg_8bit_len equ $ - msg_8bit

    msg_reg2reg db "Register-to-register: mov rbx, rax", 10
    msg_reg2reg_len equ $ - msg_reg2reg

    msg_footer  db "--- done ---", 10
    msg_footer_len equ $ - msg_footer

section .text
    global _start

_start:
    ; --- Print header ---
    mov     rax, 1              ; syscall number: sys_write
    mov     rdi, 1              ; fd: stdout
    mov     rsi, msg_header     ; pointer to string
    mov     rdx, msg_header_len ; byte count
    syscall

    ; === Demonstration 1: mov rax, imm64 ===
    ; Load a 64-bit immediate value into the full 64-bit register rax.
    ; This uses a MOVABS encoding internally (REX.W prefix + 64-bit immediate).
    ; After this instruction, rax = 0xDEADBEEFCAFEBABE
    mov     rax, 0xDEADBEEFCAFEBABE

    ; Print label for this demonstration
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_64bit
    mov     rdx, msg_64bit_len
    syscall

    ; === Demonstration 2: mov eax, imm32 -- the zero-extension rule ===
    ; Writing to eax (32-bit register) ALWAYS zero-extends to the full 64-bit rax.
    ; This is an x86-64 design decision: any write to a 32-bit register
    ; silently clears bits 32-63 of the corresponding 64-bit register.
    ;
    ; Before: rax = 0xDEADBEEFCAFEBABE (from demonstration 1)
    ; After:  rax = 0x0000000012345678 (upper 32 bits zeroed!)
    ;
    ; Contrast with ax/al below -- those do NOT zero the upper bits.
    mov     eax, 0x12345678     ; upper 32 bits of rax are silently cleared

    ; Print label (we must reload rax for the syscall; that's fine -- syscall clobbers rax)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_32bit
    mov     rdx, msg_32bit_len
    syscall

    ; Set up rax with a known full 64-bit value for the next two demonstrations
    ; We want to show that ax and al writes do NOT clear the upper bits.
    mov     rax, 0xAAAAAAAAAAAAAAAA   ; 64-bit value: all A's

    ; === Demonstration 3: mov ax, imm16 -- upper bits PRESERVED ===
    ; Writing to ax (16-bit sub-register) only modifies bits 0-15 of rax.
    ; Bits 16-63 of rax are UNCHANGED.
    ;
    ; Before: rax = 0xAAAAAAAAAAAAAAAA
    ; After:  rax = 0xAAAAAAAAAAAABBBB  (only lower 16 bits changed)
    mov     ax, 0xBBBB          ; only bits 0-15 of rax change

    ; Print label
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_16bit
    mov     rdx, msg_16bit_len
    syscall

    ; Set up rax again (sys_write clobbered it)
    mov     rax, 0xAAAAAAAAAAAAAAAA   ; restore for al demonstration

    ; === Demonstration 4: mov al, imm8 -- upper bits PRESERVED ===
    ; Writing to al (8-bit sub-register) only modifies bits 0-7 of rax.
    ; Bits 8-63 of rax are UNCHANGED.
    ;
    ; Before: rax = 0xAAAAAAAAAAAAAAAA
    ; After:  rax = 0xAAAAAAAAAAAAAACC  (only lower 8 bits changed)
    mov     al, 0xCC            ; only bits 0-7 of rax change

    ; Print label
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_8bit
    mov     rdx, msg_8bit_len
    syscall

    ; === Demonstration 5: register-to-register copy ===
    ; mov can copy from one register to another.
    ; After syscall, rax is clobbered, but rbx is a callee-saved register
    ; and we haven't touched it -- it still holds its original value.
    ; We'll load rax with a known value and copy it to rbx.
    mov     rax, 0x1234567890ABCDEF   ; load rax with a known value
    mov     rbx, rax                   ; copy rax to rbx -- register-to-register mov

    ; Print label
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_reg2reg
    mov     rdx, msg_reg2reg_len
    syscall

    ; --- Print footer ---
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_footer
    mov     rdx, msg_footer_len
    syscall

    ; === Exit ===
    ; sys_exit(status=0) -- clean program termination
    mov     rax, 60             ; syscall number: sys_exit
    xor     rdi, rdi            ; exit code 0 (xor reg,reg is the idiomatic zero)
    syscall
