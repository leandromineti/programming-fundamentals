# asm-01-mov: Register Sizes and the MOV Instruction

## Concept

x86-64 registers are layered: each 64-bit register has named sub-registers for the lower 32, 16, and 8 bits.

For `rax` (the 64-bit accumulator), the sub-registers are:

```
63       32 31      16 15     8 7      0
|    rax    |         |        |       |
            |   eax   |        |       |
                      |   ax   |       |
                      |   ah   |  al   |
```

**The zero-extension rule** is the most important detail in this exercise:

- Writing to `eax` (32-bit) **always clears bits 32-63 of rax**. This is by x86-64 design.
- Writing to `ax` (16-bit) or `al` / `ah` (8-bit) does **not** affect the upper bits.

This asymmetry catches many beginners. If you write `mov eax, 1`, you get
`rax = 0x0000000000000001`, not `rax = 0xXXXXXXXX00000001`. The upper half is gone.

## Build and Run

```bash
make build    # assemble and link main.asm -> main
make run      # build and execute
make check    # build, run, compare output to expected_output (prints PASS or FAIL)
make clean    # remove generated files
```

## What to Observe

Read through `main.asm` and notice:

- `mov rax, 0xDEADBEEFCAFEBABE` -- 64-bit immediate load (REX.W prefix, 8-byte immediate)
- `mov eax, 0x12345678` -- 32-bit immediate load; the upper 32 bits of `rax` silently become 0
- `mov ax, 0xBBBB` -- 16-bit sub-register write; the upper 48 bits of `rax` are unchanged
- `mov al, 0xCC` -- 8-bit sub-register write; the upper 56 bits of `rax` are unchanged
- `mov rbx, rax` -- register-to-register copy; both registers hold the same value after this

Each `mov` variant is followed by a `sys_write` syscall (which clobbers `rax`), so the
code sets `rax` to known values at the start of each demonstration. This is intentional --
it makes each demonstration independent and readable.

## Try Modifying

1. **Change the 64-bit immediate**: Replace `0xDEADBEEFCAFEBABE` with a different value. Reassemble and check that `make check` still passes (the output messages don't change).

2. **Verify zero-extension in GDB**: Set a breakpoint after `mov rax, 0xDEADBEEFCAFEBABE`, then step through `mov eax, 0x12345678` and watch `rax` in the register panel change from `0xDEADBEEFCAFEBABE` to `0x0000000012345678`.

3. **Test non-zero-extension for ax**: Before `mov ax, 0xBBBB`, add `mov rax, 0xFFFFFFFFFFFFFFFF`. After the `ax` write, `rax` should be `0xFFFFFFFFFFFFBBBB` (upper 48 bits unchanged). Verify in GDB.

4. **Swap ax and al writes**: Comment out the `mov ax` line and add `mov al, 0x77` instead. What does `rax` look like? Only bits 0-7 change.

## How to inspect this program in GDB

Start GDB with TUI mode (source + assembly side-by-side):

```
gdb -tui ./main
```

Five-command starter kit:

1. `break _start` -- set a breakpoint at the program entry point
2. `run` -- execute until the breakpoint hits
3. `info registers rax rbx` -- inspect the current values of rax and rbx
4. `si` -- step one instruction (single-step at the machine instruction level)
5. `info registers rax rbx` -- inspect again after the step and compare

Repeat `si` + `info registers rax rbx` to trace the effect of each `mov` instruction.

After each `si`, observe the register panel -- GEF highlights changed registers in color.
The delta between steps makes the zero-extension rule immediately visible: after
`mov eax, 0x12345678`, the GEF panel will show `rax` changed from `0xDEADBEEFCAFEBABE`
to `0x0000000012345678`, with the changed bits highlighted.

**Note:** We pass the integer argument in `rdi` when calling `print_uint64` -- you'll learn
exactly why in Phase 2 (calling conventions).
