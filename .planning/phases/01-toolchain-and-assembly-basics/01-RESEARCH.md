# Phase 1: Toolchain and Assembly Basics - Research

**Researched:** 2026-04-06
**Domain:** WSL2 toolchain setup + NASM x86-64 assembly (registers, arithmetic, control flow, memory addressing)
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**D-01:** All assembly programs produce verifiable output via Linux syscalls (sys_write to stdout, sys_exit) — no libc dependency

**D-02:** A shared `print_uint64` helper routine is provided in `lib/` for exercises that need to print numeric results. Students include it; the conversion logic is not the focus of early exercises

**D-03:** Text strings are defined in `section .data` with labels using `db` — standard NASM pattern

**D-04:** One directory per exercise, grouped under topic directories: `01-registers/asm-01-mov/`, `02-flow-control/asm-03-conditionals/`, `03-memory/asm-05-data-bss/`, etc.

**D-05:** Shared helpers live in `lib/` at the project root (e.g., `lib/print_uint64.asm`). Exercise Makefiles reference `../../lib/` or equivalent relative path

**D-06:** The main source file in each exercise directory is always named `main.asm`

**D-07:** Exercises are delivered as complete, working programs that demonstrate the concept. The student reads, runs, modifies, and experiments

**D-08:** Each exercise has a README.md explaining the concept briefly, listing what to observe, and suggesting modifications to try. Code has inline comments explaining each instruction

**D-09:** All READMEs, code comments, and documentation are in English

**D-10:** `make check` runs the program, captures stdout, and compares byte-for-byte against an `expected_output` file using `diff -u`. Prints PASS on match, FAIL with visible diff on mismatch

**D-11:** A root-level Makefile provides `make check-all` that recursively runs `make check` in every exercise directory

**D-12:** Comparison is exact (byte-for-byte) — no whitespace tolerance. Exercises teach precise output production

### Claude's Discretion

- Exact content and progression within each exercise
- How print_uint64 helper is implemented internally
- Makefile variable naming and internal structure
- README depth and structure (within the "concept + annotations" framework)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| TOOL-01 | WSL2 environment configured with NASM, GCC, Make, and GDB | Installation sequence verified; NASM 2.16.x from apt is sufficient; GDB + GEF setup documented |
| TOOL-02 | Build system with per-module Makefile (compile and run with one command) | Per-exercise Makefile pattern with `build`, `run`, `check`, `clean` targets documented below |
| TOOL-03 | Exercise verification via diff against expected output (no test framework) | `diff -u expected_output actual.txt` pattern confirmed; aligns with D-10 and D-12 |
| ASM-01 | Exercise with mov between registers and immediates (understand sizes: rax, eax, ax, al) | Zero-extension rule for 32-bit writes documented; all four widths covered in code examples |
| ASM-02 | Exercise with add, sub, imul, idiv — arithmetic operations with registers | `idiv` requires `cqo` for sign-extension of rax into rdx:rax; documented in pitfalls |
| ASM-03 | Exercise with cmp and conditional jumps (je, jne, jl, jg) — control flow | FLAGS register mechanics and full jcc family documented |
| ASM-04 | Exercise with simple loop using register counter | Counter-in-register loop pattern with `dec` + `jnz` documented |
| ASM-05 | Exercise accessing data in .data and .bss (global variables) | NASM section syntax, `db`/`dq`/`resq` directives documented; matches D-03 |
| ASM-06 | Exercise with addressing modes: direct, indirect [reg], base+offset [reg+N] | All three modes documented with concrete NASM syntax |
| ASM-07 | Exercise iterating over an array in memory using indexed addressing | `[base + index*scale + displacement]` form with SIB byte documented |
</phase_requirements>

---

## Summary

Phase 1 establishes the complete development environment and delivers seven assembly exercises covering the foundational x86-64 instruction set. The toolchain (NASM, GCC, Make, GDB+GEF) installs entirely from `apt` on Ubuntu 24.04 in WSL2. No version conflicts, no source compilation required.

The key architectural decision already locked in CONTEXT.md is that all programs output via Linux syscalls (`sys_write=1`, `sys_exit=60`) with no libc dependency. This is the purest approach for learning — the student sees exactly what a program must do to interact with the OS. The tradeoff is that numeric output requires a `print_uint64` helper in `lib/`; that helper becomes the first instance of the lib-inclusion pattern exercises will use throughout.

The exercise structure follows a demonstrated-then-explored pattern (D-07): complete working programs with heavy inline annotation, not stubs. The `diff`-based verification (D-10, D-12) requires every exercise to produce byte-for-byte deterministic stdout, which constrains exercise design: arithmetic results must be printed, loop counts must be printed, memory reads must be printed. The `print_uint64` helper in `lib/` is the enabler for all numeric output.

**Primary recommendation:** Plan execution in four sequential units — (1) toolchain setup + lib/, (2) registers topic group, (3) flow-control topic group, (4) memory topic group — with the root Makefile created alongside the first exercise and extended as each topic group is added.

---

## Project Constraints (from CLAUDE.md)

| Directive | Constraint |
|-----------|------------|
| Architecture: x86-64 only | No emulators, exercises run natively in WSL2 |
| Toolchain: open-source via WSL | NASM (nasm), GCC (gcc), GNU Make (make), GDB (gdb) — all from apt |
| Format: every exercise must compile and execute with clear instructions | Makefile per exercise; no exercise without a working build |
| Assembler: NASM with Intel syntax | Intel syntax throughout — GDB `set disassembly-flavor intel`, no AT&T |
| Compiler: GCC 14.2.0 (Ubuntu 24.04 default) | `-g`, `-O0`, `-Og`, `-fno-omit-frame-pointer`, `-masm=intel` flags |
| Build system: GNU Make | Per-exercise Makefile; root Makefile with `check-all` |
| Debugger: GDB + GEF | GEF via pip install; five-command starter kit in Phase 1 |

---

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|---|---|---|---|
| NASM | 2.16.x (apt on Ubuntu 24.04) | Assembles `.asm` source files | Intel syntax matches ISA documentation; most x86-64 learning material uses NASM. Version 2.16.x from apt is fully sufficient for this phase — NASM 3.x APX extensions are not needed [VERIFIED: CLAUDE.md + STACK.md] |
| GNU Make | 4.3+ (system) | Per-exercise build automation | Makefile is itself educational; incremental builds; standard `make check` / `make clean` targets [VERIFIED: CLAUDE.md] |
| GDB | 15.x (system) | Step through assembly instruction-by-instruction | Canonical Linux debugger; TUI mode; WSL2 native [VERIFIED: CLAUDE.md + STACK.md] |
| GEF | latest (pip3) | GDB enhancement — register panel, color deltas | Colored register diff after each `si` is the difference between understanding and confusion for beginners [VERIFIED: CLAUDE.md + STACK.md] |
| GCC | 14.2.0 (system) | Used in Phase 1 only for linking: `gcc -no-pie` to link NASM `.o` files against libc-free executables | Available by default; using `ld` directly requires explicit linker script for standard entry point [VERIFIED: CLAUDE.md] |

### Supporting
| Tool | Version | Purpose | When to Use |
|---|---|---|---|
| objdump | system (GNU Binutils 2.42) | Disassemble, inspect ELF sections | `objdump -d -M intel main` to inspect generated machine code; `-h` to show section headers [VERIFIED: CLAUDE.md] |
| Linux syscall ABI | kernel 5.15+ (WSL2) | sys_write (rax=1), sys_exit (rax=60) | Every exercise in Phase 1 uses these two syscalls for all output and exit [VERIFIED: cited from CONTEXT.md D-01] |

### Installation
```bash
# Run inside WSL2 Ubuntu 24.04 — NOT from Windows PowerShell
sudo apt update
sudo apt install -y build-essential nasm gdb binutils

# GEF (GDB enhancement)
pip3 install keystone-engine capstone unicorn
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

# Verify
nasm --version   # NASM version 2.16.x
gcc --version    # gcc (Ubuntu) 14.2.0
gdb --version    # GNU gdb 15.x
make --version   # GNU Make 4.3
```

**Version note:** `apt` on Ubuntu 24.04 installs NASM 2.16.x, not 3.01. This is correct — do not compile from source. [VERIFIED: STACK.md, CLAUDE.md]

---

## Architecture Patterns

### Phase 1 Directory Structure
```
programming-fundamentals/       ← WSL2 native fs: ~/projects/... NOT /mnt/c/
├── Makefile                    ← root: check-all, clean-all
├── lib/
│   └── print_uint64.asm        ← shared helper; included by arithmetic exercises
├── 01-registers/
│   ├── asm-01-mov/
│   │   ├── main.asm            ← always named main.asm (D-06)
│   │   ├── expected_output     ← byte-for-byte expected stdout (D-10)
│   │   ├── Makefile
│   │   └── README.md
│   └── asm-02-arithmetic/
│       ├── main.asm
│       ├── expected_output
│       ├── Makefile
│       └── README.md
├── 02-flow-control/
│   ├── asm-03-conditionals/
│   │   └── ...
│   └── asm-04-loop/
│       └── ...
└── 03-memory/
    ├── asm-05-data-bss/
    ├── asm-06-addressing/
    └── asm-07-array-iteration/
```

**Topic group naming:** Three groups align with REQUIREMENTS.md groupings — `01-registers` (ASM-01, ASM-02), `02-flow-control` (ASM-03, ASM-04), `03-memory` (ASM-05, ASM-06, ASM-07). The prefix numbers provide shell glob ordering for `make check-all`.

### Pattern 1: Per-Exercise Makefile with lib/ inclusion
**What:** Each exercise's Makefile assembles `main.asm` plus any dependencies from `lib/`, links with `ld`, and provides `build`, `run`, `check`, `clean` targets.
**When to use:** All seven exercises in this phase.

```makefile
# Source: derived from ARCHITECTURE.md + CONTEXT.md D-05 (lib/ reference)
ASM      = nasm
LD       = ld
ASMFLAGS = -f elf64 -g

SRC      = main.asm
OBJ      = main.o
LIB_OBJ  = ../../lib/print_uint64.o
BIN      = main

.PHONY: build run check clean

build: $(BIN)

$(BIN): $(OBJ) $(LIB_OBJ)
	$(LD) -o $@ $^

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(LIB_OBJ): ../../lib/print_uint64.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

run: build
	./$(BIN)

check: build
	./$(BIN) > actual.txt
	diff -u expected_output actual.txt && echo "PASS" || (echo "FAIL"; rm -f actual.txt; exit 1)
	@rm -f actual.txt

clean:
	rm -f $(OBJ) $(BIN) actual.txt
```

**Note:** Exercises that do not need `print_uint64` (e.g., asm-01-mov which only prints strings) omit `$(LIB_OBJ)` and the lib build rule. The Makefile structure is identical in all other respects.

### Pattern 2: Root Makefile — check-all with tolerant counting
**What:** Root Makefile iterates over all exercise directories, runs `make check -s` in each, tallies PASS/FAIL without aborting on failure.
**When to use:** Root level only. Always tolerates failures — stub exercises that haven't been implemented yet should not block the full run.

```makefile
# Source: ARCHITECTURE.md root Makefile pattern + adjusted for D-11 (check-all)
EXERCISES := \
  01-registers/asm-01-mov \
  01-registers/asm-02-arithmetic \
  02-flow-control/asm-03-conditionals \
  02-flow-control/asm-04-loop \
  03-memory/asm-05-data-bss \
  03-memory/asm-06-addressing \
  03-memory/asm-07-array-iteration

.PHONY: check-all clean-all

check-all:
	@pass=0; fail=0; \
	for ex in $(EXERCISES); do \
	  if $(MAKE) -C $$ex check -s 2>/dev/null; then \
	    echo "PASS  $$ex"; pass=$$((pass+1)); \
	  else \
	    echo "FAIL  $$ex"; fail=$$((fail+1)); \
	  fi; \
	done; \
	echo ""; echo "Results: $$pass passed, $$fail failed"

clean-all:
	@for ex in $(EXERCISES); do \
	  $(MAKE) -C $$ex clean -s 2>/dev/null || true; \
	done
	rm -f lib/print_uint64.o
```

### Pattern 3: Syscall-only output — sys_write + sys_exit skeleton
**What:** Every program in this phase uses Linux syscalls directly. No libc. This is locked by D-01.
**When to use:** All seven exercises.

```nasm
; Source: Linux x86-64 syscall ABI — syscall numbers from /usr/include/asm/unistd_64.h
; [CITED: https://www.nasm.us/doc/ + https://man7.org/linux/man-pages/man2/syscall.2.html]

section .data
    msg db "Hello, registers!", 10   ; 10 = newline (LF)
    msg_len equ $ - msg

section .text
    global _start

_start:
    ; sys_write(fd=1, buf=msg, count=msg_len)
    mov     rax, 1          ; syscall number: sys_write
    mov     rdi, 1          ; fd: stdout
    mov     rsi, msg        ; pointer to string
    mov     rdx, msg_len    ; byte count
    syscall

    ; sys_exit(status=0)
    mov     rax, 60         ; syscall number: sys_exit
    xor     rdi, rdi        ; exit code 0
    syscall
```

**Linker command:** `ld -o main main.o` — uses `_start` as entry point. No libc, no CRT startup code.

### Pattern 4: print_uint64 helper — integer-to-string via div loop
**What:** Shared assembly routine in `lib/print_uint64.asm` that converts a 64-bit unsigned integer in `rdi` to decimal ASCII and writes it to stdout via `sys_write`. Treated as a black box by students in this phase.
**When to use:** ASM-02 (arithmetic results), ASM-04 (loop counter), ASM-07 (array iteration results).

```nasm
; Source: standard integer-to-ASCII pattern for x86-64 assembly
; [ASSUMED] — the internal algorithm below is the canonical div-loop approach;
; specific implementation is Claude's discretion per CONTEXT.md
;
; Interface contract:
;   Input:  rdi = 64-bit unsigned integer to print
;   Output: integer printed to stdout followed by newline
;   Clobbers: rax, rbx, rcx, rdx, rsi, r8 (caller must save if needed)
;   Does NOT preserve any registers — pure leaf function using only scratch regs

global print_uint64

section .bss
    .buf resb 21        ; max 20 digits for UINT64_MAX + newline

section .text
print_uint64:
    ; ... div loop: repeatedly divide rdi by 10, collect remainders, reverse, sys_write
    ; Implementation detail — not the focus of Phase 1 exercises
    ret
```

**Key constraint:** The helper uses System V calling convention — argument in `rdi`. This foreshadows Phase 2 (calling conventions) without requiring the student to understand it yet. A comment in the exercise README notes: "We pass the number in rdi — you'll learn exactly why in Phase 2."

### Anti-Patterns to Avoid
- **Using `int 0x80` syscalls:** This is the 32-bit Linux ABI. x86-64 uses `syscall` instruction. Watch for: any tutorial using `int 0x80` or passing syscall number in `eax` (not `rax`).
- **Linking with gcc instead of ld for pure assembly:** `gcc main.o -o main` pulls in CRT startup code and expects `main` not `_start`. Use `ld -o main main.o` for pure assembly programs with no libc.
- **AT&T syntax in GDB:** After installing GEF, GDB still defaults to AT&T syntax for disassembly. Fix: add `set disassembly-flavor intel` to `~/.gdbinit`. Without this, `x/3i $rip` output will be in AT&T syntax, contradicting the NASM source.
- **Forgetting `global _start`:** NASM does not export symbols by default. Without `global _start`, the linker produces "undefined reference to _start" — a cryptic error for beginners.
- **Writing to eax/ax/al when rax content must be preserved:** Writing to `eax` zero-extends into `rax`. Writing to `ax` or `al` does NOT. Using the wrong width leaves stale high bits that silently corrupt subsequent operations.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Integer-to-string conversion | Custom div loop per exercise | `lib/print_uint64.asm` | Non-trivial to get right (null case, sign, buffer reversal); the conversion logic is not the learning objective of arithmetic exercises [ASSUMED — standard learning repo pattern] |
| Expected output files | Runtime string comparison in assembly | `expected_output` text file + `diff` | Assembly string comparison is a Phase 2+ topic; diff is zero-complexity from the learner's perspective [VERIFIED: CONTEXT.md D-10] |
| Test framework for output verification | Custom harness with assertion macros | `diff -u expected_output actual.txt` | No dependencies, no build complexity, works for all exercises whose success criterion is deterministic stdout [VERIFIED: REQUIREMENTS.md TOOL-03, CONTEXT.md D-10] |

**Key insight:** The verification mechanism is intentionally primitive. `diff` is not a testing framework — it is a Unix tool the student already knows. Keeping it primitive means the build system never becomes an obstacle between the student and the assembly.

---

## Runtime State Inventory

Step 2.5: SKIPPED. This is a greenfield phase — no rename, refactor, or migration involved. No runtime state exists to inventory.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| WSL2 Ubuntu 24.04 | All exercises | [ASSUMED] — confirmed by PITFALLS.md and STATE.md references to WSL2 | Ubuntu 24.04 | No fallback — exercises require Linux kernel; native Linux also works |
| NASM | All exercises | [ASSUMED] — apt package on Ubuntu 24.04 | 2.16.x | No fallback — NASM is the locked assembler |
| GCC (build-essential) | Makefile (ld comes from binutils; gcc may be used for linking) | [ASSUMED] — Ubuntu 24.04 default | 14.2.0 | No fallback |
| GNU Make | All Makefiles | [ASSUMED] — Ubuntu 24.04 default | 4.3+ | No fallback |
| GDB | Debugging workflow | [ASSUMED] — installed via apt | 15.x | No GEF without GDB |
| GEF | GDB enhancement | [ASSUMED] — pip3 install | latest | Fallback: vanilla GDB (functional but less readable) |
| Python3 + pip3 | GEF installation | [ASSUMED] — Ubuntu 24.04 default | 3.12+ | Needed only for GEF; vanilla GDB works without it |

**CRITICAL environment note:** The project repository must live on the WSL2 native filesystem (`~/...`), NOT on `/mnt/c/...`. This is the single most impactful setup decision. STATE.md §Blockers confirms this. A Wave 0 task should verify filesystem location and, if wrong, re-clone.

**Missing dependencies with no fallback:** None detected — all required tools are standard Ubuntu 24.04 packages. The only risk is the filesystem location (not a package availability issue).

**Missing dependencies with fallback:**
- GEF: if pip3 install fails, vanilla GDB is functional. GEF is strongly recommended but not blocking.

---

## Common Pitfalls

### Pitfall 1: Repository on Windows Filesystem (/mnt/c/...)
**What goes wrong:** Build operations run through WSL2's 9P filesystem bridge, producing noticeable sluggishness on every compile-run cycle.
**Why it happens:** Repo cloned from Windows Explorer into `C:\Users\...`, which WSL2 mounts as `/mnt/c/Users/...`.
**How to avoid:** Before creating any exercises, verify `pwd` inside WSL2 starts with `~/` or `/home/`. If it starts with `/mnt/c/`, re-clone into WSL2 native filesystem.
**Warning signs:** `pwd` shows `/mnt/c/...` in WSL2 terminal.
**Source:** [VERIFIED: PITFALLS.md, Microsoft WSL docs — https://learn.microsoft.com/en-us/windows/wsl/compare-versions]

### Pitfall 2: GDB Disassembly in AT&T Syntax
**What goes wrong:** GEF/GDB defaults to AT&T syntax. Student sees `mov %rdi, %rax` while their NASM source reads `mov rax, rdi`. Operands are reversed. Confusion compounds quickly.
**Why it happens:** GDB default is AT&T; this is not changed by the GEF installation.
**How to avoid:** Add `set disassembly-flavor intel` to `~/.gdbinit` as part of the toolchain setup task. Verify with `x/3i $rip` after break — output should show `mov rax, ...` not `mov ..., %rax`.
**Warning signs:** Register names have `%` prefix or mnemonic has size suffix (`movq`, `pushq`) in GDB output.
**Source:** [VERIFIED: PITFALLS.md + STACK.md + GDB docs — https://sourceware.org/gdb/documentation/]

### Pitfall 3: idiv Sign Extension — Missing `cqo` Before Division
**What goes wrong:** `idiv` divides `rdx:rax` (the 128-bit pair) by the operand. If `rdx` is not initialized as the sign extension of `rax`, the result is garbage or a fault.
**Why it happens:** Beginners see "divide rax by rcx" and write `idiv rcx` without setting up `rdx`.
**How to avoid:** Always precede `idiv` with `cqo` (convert quadword to octword) which sign-extends `rax` into `rdx:rax`. Document in ASM-02 exercise comment.
**Warning signs:** Division produces wildly wrong results or raises `SIGFPE` (divide error exception).
**Source:** [CITED: Intel SDM Vol. 2A — IDIV instruction entry; https://www.nasm.us/doc/nasmdocb.html]

### Pitfall 4: Forgetting `global _start` in NASM Source
**What goes wrong:** Linker reports "undefined reference to `_start`" or "cannot find entry symbol".
**Why it happens:** NASM does not export symbols globally by default. The linker needs `_start` to be visible.
**How to avoid:** Every `main.asm` template includes `global _start` as boilerplate — it should be present before the student edits anything.
**Warning signs:** Linker error mentioning `_start` during `make build`.
**Source:** [CITED: NASM docs — https://www.nasm.us/doc/nasmdo10.html#section-10.1]

### Pitfall 5: 32-bit Resources and `int 0x80` Syscall Confusion
**What goes wrong:** Web search results for "x86 assembly hello world" return 32-bit content using `int 0x80`, stack-passed arguments, `eax` for syscall number. None of this applies to x86-64.
**Why it happens:** 32-bit x86 assembly has much more web presence than x86-64.
**How to avoid:** Every exercise README links only x86-64 resources. Detection test: if a resource uses `int 0x80` or passes arguments to functions by pushing them on the stack, it is 32-bit. README.md notes explicitly: "This is x86-64. Syscall mechanism is `syscall` not `int 0x80`. Arguments go in rdi, rsi, rdx... not on the stack."
**Warning signs:** Seeing `int 0x80` in any tutorial; syscall number in `eax` not `rax`.
**Source:** [VERIFIED: PITFALLS.md + Linux kernel syscall table x86-64]

### Pitfall 6: eax Write Zero-Extends rax — ax/al Write Does Not
**What goes wrong:** Writing to `eax` clears the upper 32 bits of `rax`. Writing to `ax` or `al` leaves upper bits unchanged. Mixing widths produces stale-bit bugs that manifest as seemingly random wrong values.
**Why it happens:** This is a deliberate x86-64 design choice (32-bit write always zero-extends) that surprises everyone.
**How to avoid:** ASM-01 (mov exercise) must demonstrate this explicitly — show with GDB that `mov eax, 1` clears `rax` upper bits, while `mov al, 1` does not. Use `info registers` to verify after each variant.
**Warning signs:** A register holds a value larger than expected after a narrow write.
**Source:** [VERIFIED: PITFALLS.md + Intel SDM — "Effect of 32-bit register write on 64-bit register"]

### Pitfall 7: `expected_output` File Missing Trailing Newline
**What goes wrong:** The program outputs a newline after its last line (syscall writes `"value\n"`), but the `expected_output` file was created without a trailing newline (e.g., via echo with `-n` or a text editor that strips trailing newlines). `diff` reports a mismatch even though the output looks identical.
**Why it happens:** The byte-for-byte comparison (D-12) is unforgiving. A single missing or extra newline byte causes FAIL.
**How to avoid:** Create `expected_output` files with explicit `printf 'value\n' > expected_output` (not `echo -n`). Verify with `xxd expected_output | tail -2` that the last byte is `0a` (newline).
**Warning signs:** `diff` shows a single `\` at the end of the expected line (indicating no trailing newline).
**Source:** [ASSUMED — standard diff pitfall for byte-exact comparison]

---

## Code Examples

Verified patterns from official and project-specific sources:

### Complete Skeleton: string output via sys_write
```nasm
; Source: Linux x86-64 syscall ABI
; [CITED: https://man7.org/linux/man-pages/man2/write.2.html + syscall table]

section .data
    msg     db  "rax = 42", 10      ; string + LF; D-03 pattern
    msg_len equ $ - msg             ; length computed by assembler

section .text
    global _start                   ; REQUIRED — linker entry point

_start:
    mov     rax, 1                  ; sys_write
    mov     rdi, 1                  ; fd = stdout
    mov     rsi, msg                ; buf pointer
    mov     rdx, msg_len            ; byte count
    syscall

    mov     rax, 60                 ; sys_exit
    xor     rdi, rdi                ; status = 0
    syscall
```

### Register Width Demonstration (ASM-01)
```nasm
; Demonstrates zero-extension rule: writing eax clears upper 32 bits of rax
; [CITED: Intel SDM Vol. 1, Section 3.4.1.1]

    mov     rax, 0xDEADBEEFCAFEBABE ; set all 64 bits
    mov     eax, 0x0000_0001        ; writes lower 32, CLEARS upper 32 → rax = 1
    ; After: rax = 0x0000000000000001 (not 0xDEADBEEF00000001)

    mov     rax, 0xDEADBEEFCAFEBABE ; reset
    mov     ax,  0x0001             ; writes lower 16, upper bits UNCHANGED
    ; After: rax = 0xDEADBEEFCAFEBABE & 0xFFFFFFFFFFFF0000 | 0x0001
```

### Arithmetic with idiv (ASM-02)
```nasm
; CRITICAL: idiv divides rdx:rax by operand. Must sign-extend rax into rdx first.
; [CITED: Intel SDM Vol. 2A — IDIV reference; NASM docs Section B.4.12]

    mov     rax, 17         ; dividend
    mov     rcx, 5          ; divisor
    cqo                     ; sign-extend rax → rdx:rax (rdx = 0 if rax ≥ 0)
    idiv    rcx             ; rax = quotient (3), rdx = remainder (2)
```

### Conditional Jump (ASM-03)
```nasm
; cmp sets FLAGS; jcc tests FLAGS without modifying registers
; [CITED: Intel SDM Vol. 2A — CMP and Jcc entries]

    mov     rax, 10
    mov     rbx, 20
    cmp     rax, rbx        ; computes rax - rbx, sets FLAGS, discards result
    jl      less_than       ; jump if rax < rbx (signed: SF ≠ OF)
    ; ... equal or greater branch ...
less_than:
    ; ... less-than branch ...
```

### Counter Loop (ASM-04)
```nasm
; Simple countdown loop: rcx as counter, dec + jnz as loop mechanism
; [CITED: Intel SDM Vol. 2A — DEC, JNZ entries]

    mov     rcx, 5          ; loop 5 times

.loop_top:
    ; ... loop body using rcx as iteration variable or separate register ...
    dec     rcx             ; decrement counter; sets ZF if rcx reaches 0
    jnz     .loop_top       ; jump if ZF=0 (counter not yet zero)
```

**Note on rcx:** The `loop` instruction (legacy) implicitly uses `rcx` and is slower on modern CPUs. Prefer `dec + jnz` explicitly for clarity and performance.

### Data and BSS Sections (ASM-05)
```nasm
; .data: initialized data — loaded from ELF file; read-only unless mapped rw
; .bss:  uninitialized data — zero-initialized at load time; no file space
; [CITED: NASM docs Section 7.1; ELF specification]

section .data
    count   dq  42          ; 64-bit initialized variable
    label   db  "answer: ", 0

section .bss
    result  resq 1          ; reserve 1 quadword (8 bytes), zero-initialized

section .text
    global _start
_start:
    mov     rax, [count]    ; load 64-bit value from .data
    add     rax, 10
    mov     [result], rax   ; store to .bss
```

### Addressing Modes (ASM-06)
```nasm
; Three modes: direct, register-indirect, base+displacement
; [CITED: Intel SDM Vol. 2A — MOV reference; NASM docs Section 3.3]

section .data
    value   dq  100

section .text
_start:
    ; Direct (label is resolved to absolute address by linker)
    mov     rax, [value]            ; load from label address

    ; Register-indirect
    mov     rbx, value              ; rbx = address of value
    mov     rax, [rbx]              ; load from address in rbx

    ; Base + displacement
    mov     rax, [rbx + 8]          ; load 8 bytes after rbx (next element)
```

### Indexed Array Iteration (ASM-07)
```nasm
; Full SIB addressing: [base + index*scale + displacement]
; [CITED: Intel SDM Vol. 2A — MOV reference; https://www.nasm.us/doc/nasmdocb.html]

section .data
    arr     dq  10, 20, 30, 40, 50  ; array of 5 64-bit integers
    arr_len equ 5

section .text
_start:
    mov     rbx, arr        ; base pointer
    xor     rcx, rcx        ; index = 0

.loop:
    mov     rax, [rbx + rcx*8]  ; load arr[rcx]; scale=8 for dq (64-bit)
    ; ... process rax (print via print_uint64 helper) ...
    inc     rcx
    cmp     rcx, arr_len
    jl      .loop
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|---|---|---|---|
| `loop` instruction for counted loops | `dec reg; jnz label` | x86 architecture historical | `loop` is slower on modern OOO CPUs (implicit rcx dependency); explicit `dec+jnz` is standard in all modern assembly code [ASSUMED — well-known CPU microarchitecture fact] |
| `int 0x80` Linux syscalls | `syscall` instruction | x86-64 introduction (2003) | 32-bit vs 64-bit calling convention; Phase 1 uses `syscall` exclusively |
| GAS (AT&T syntax) as default learning assembler | NASM (Intel syntax) as learning assembler | Community consensus shift ~2015 | Intel syntax matches official documentation and most learning resources; AT&T is reserved for reading GCC output |

**Deprecated/outdated:**
- `int 0x80`: 32-bit Linux syscall mechanism. Do not use. Phase 1 uses `syscall` instruction only.
- `loop rcx_label`: Valid but slow. Reserved for historical discussion; practical loops use `dec + jnz`.
- PEDA (GDB plugin): Python 2, unmaintained. Replaced by GEF.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | `lib/print_uint64.asm` internal implementation uses div loop to convert integer to decimal ASCII | Architecture Patterns — Pattern 4 | Low: implementation is Claude's discretion per CONTEXT.md; any correct implementation works |
| A2 | WSL2 Ubuntu 24.04 environment is already installed and running on the developer's machine | Environment Availability | High: if WSL2 is not installed, Wave 0 toolchain tasks cannot proceed. Verify before execution. |
| A3 | GEF installation via `bash -c "$(curl -fsSL https://gef.blah.cat/sh)"` is current and stable | Standard Stack | Low: GEF fallback is vanilla GDB; functional if not ideal |
| A4 | `loop` instruction is slower than `dec+jnz` on modern CPUs | State of the Art | Low: both produce correct results; performance claim does not affect correctness of exercises |
| A5 | `expected_output` file content can be created during exercise authoring by running the reference implementation | Architecture Patterns | Low: expected_output is always author-controlled; it is not generated by an external system |

---

## Open Questions

1. **lib/ build dependency management**
   - What we know: Exercise Makefiles reference `../../lib/print_uint64.o`. Make will build it if the rule is present, but each exercise's Makefile duplicating the lib build rule creates redundancy.
   - What's unclear: Should `lib/` have its own Makefile with a `make -C ../../lib` call? Or should each exercise Makefile include the rule inline?
   - Recommendation: Include the lib build rule inline in each exercise Makefile for Phase 1 (7 exercises, low duplication cost). Introduce a `lib/Makefile` in Phase 2 when the helper is used more widely.

2. **GDB starter kit format**
   - What we know: PITFALLS.md specifies five commands: `break`, `run`, `info registers`, `x/16xb $rsp`, `si`. STATE.md notes GDB must be introduced in Phase 1.
   - What's unclear: Should the GDB starter kit be a standalone `DEBUGGING.md` in the repo root, embedded in the toolchain setup task, or included in the first exercise's README?
   - Recommendation: Embed GDB usage in the README of `asm-01-mov` (the first exercise). A section titled "How to inspect this program in GDB" with the five-command walkthrough. This ties the debugger introduction to a concrete, working program rather than an abstract setup doc.

3. **Expected output format for numeric exercises**
   - What we know: `print_uint64` prints a number followed by a newline. Byte-for-byte comparison is required (D-12).
   - What's unclear: Should arithmetic exercises print a label alongside the number (e.g., `result: 42\n`) or just the number (`42\n`)? Labels make output more readable but require the label string in the program.
   - Recommendation: Print just the number followed by newline for arithmetic/loop exercises. Keep the output contract minimal — one number per line. The label goes in the README, not the program output.

---

## Sources

### Primary (HIGH confidence)
- NASM documentation — https://www.nasm.us/doc/ — syscall patterns, `global _start`, addressing modes, section directives
- Linux x86-64 syscall table — https://man7.org/linux/man-pages/man2/syscall.2.html — sys_write=1, sys_exit=60
- Intel SDM Vol. 2A — https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html — IDIV, MOV, CMP, JCC, DEC instruction references
- Project CLAUDE.md — locked toolchain decisions, GCC flags, NASM version
- Project CONTEXT.md (01-CONTEXT.md) — all D-0x locked decisions
- Project STACK.md — verified tool versions and installation commands
- Project ARCHITECTURE.md — Makefile patterns, directory structure
- Project PITFALLS.md — WSL2 filesystem pitfall, GDB syntax pitfall, 32-bit resource pitfall
- System V AMD64 ABI — https://wiki.osdev.org/System_V_ABI — calling convention (relevant for lib/ helper interface)

### Secondary (MEDIUM confidence)
- GNU Make manual — https://www.gnu.org/software/make/manual/html_node/Recursion.html — recursive Makefile for check-all
- Exercism x86-64 Assembly track — https://github.com/exercism/x86-64-assembly — Makefile and exercise structure patterns

### Tertiary (LOW confidence)
- None in this research document.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all tools confirmed in CLAUDE.md and STACK.md with verified apt package names and versions
- Architecture: HIGH — directory structure and Makefile patterns locked in CONTEXT.md decisions; patterns from ARCHITECTURE.md
- Pitfalls: HIGH — sourced from PITFALLS.md which itself cites official Microsoft WSL docs, System V ABI spec, Intel SDM
- Code examples: HIGH for syscall patterns (official Linux ABI); MEDIUM for print_uint64 internals (Claude's discretion)

**Research date:** 2026-04-06
**Valid until:** 2026-10-06 (stable toolchain domain — NASM, GCC, Make do not change frequently)
