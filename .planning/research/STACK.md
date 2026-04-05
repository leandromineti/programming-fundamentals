# Technology Stack

**Project:** programming-fundamentals (x86-64 Assembly + C)
**Researched:** 2026-04-05
**Confidence:** HIGH (all core tools verified via official sources)

---

## Recommended Stack

### Assembler

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| NASM | 3.01 (stable, 2025-10-11) | x86-64 assembly source files | Intel syntax is how Intel documents its own ISA. Every datasheet, manual, and disassembler output readable with `-M intel` flag uses this syntax. Learning AT&T (GAS) means reading `movq %rax, %rbx` instead of `mov rbx, rax` — backward operand order adds cognitive load on top of an already demanding domain. |

**Why not GAS:** GAS is the default for GCC inline assembly, but for standalone `.asm` files the AT&T syntax is a gratuitous hurdle. The Exercism x86-64 track, the majority of x86-64 learning repositories on GitHub, and Intel's own documentation all use Intel/NASM syntax. GAS should be known passively (for reading GCC output) but not used as the primary writing tool.

**Why not FASM:** Niche, smaller community, fewer learning resources. NASM has better documentation and broader adoption.

---

### Compiler

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GCC | 14.2.0 (Ubuntu 24.04 default) | Compile C exercises, generate disassembly for inspection | The reference compiler for systems-level C. CS:APP (the canonical book for this domain) uses GCC specifically. The `-Og` optimization flag was added to GCC precisely for the edit-compile-debug cycle in learning contexts — it produces assembly that maps closely to source without optimizing away the structures being studied. |

**Compilation flags for learning:**
- `-g` — include DWARF debug symbols (needed for GDB source-level stepping)
- `-O0` — for exercises focused on exact memory layout (no transformations)
- `-Og` — for exercises inspecting compiler output (minimal optimization, debuggable)
- `-fno-omit-frame-pointer` — preserve `rbp` as frame pointer; makes stack frames readable and matches calling convention exercises
- `-masm=intel` — emit GCC disassembly in Intel syntax, matching NASM notation

**Why not Clang:** Clang is excellent, but GCC is the default on Ubuntu/WSL and its disassembly output with `-S` is what most learning material references. No reason to add a second toolchain.

---

### Build System

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GNU Make | system (Ubuntu 24.04: 4.3+) | Build, run, and clean individual exercises | A Makefile is the right level of complexity here: one file, explicit rules, no abstraction between "what runs" and "what you read." This is a learning repo — the build script is itself educational. Each exercise directory gets its own `Makefile` that teaches dependency chains. |

**Why not CMake:** CMake adds a configuration layer that obscures what the linker actually does. For a project where the goal is to understand `ld`, `nasm -f elf64`, and `gcc -c`, having CMake abstract that is counterproductive. CMake is the right tool for multi-platform production code, not for a learning repo where every command in the build is a lesson.

**Why not a shell script per exercise:** Makefiles provide incremental builds (only rebuild changed files), standard targets (`make`, `make clean`, `make run`), and are universally understood. Shell scripts don't give you any of that.

---

### Debugger

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GDB | system (Ubuntu 24.04: 15.x) | Step through assembly instruction-by-instruction, inspect registers and memory | The canonical debugger for x86-64 on Linux. Runs natively in WSL2. TUI mode (`gdb -tui`) shows source and assembly side-by-side. |
| GEF | latest (pip install) | GDB enhancement — register panel, memory display, stack visualization | Vanilla GDB output is dense and hard to read. GEF renders a structured panel after each step showing all registers, their deltas, and the next 5 instructions. For a learner, seeing `rsp` change value after a `push` in a colored diff panel is the difference between understanding and confusion. |

**Why GEF over pwndbg:** pwndbg is optimized for exploit development workflows. GEF is optimized for general reverse engineering and learning — it supports more architectures and its output format is cleaner for single-step inspection. For someone learning stack frames and calling conventions (not heap exploitation), GEF is the better fit.

**Why not radare2 as primary:** radare2 has a steeper learning curve than GDB. The goal here is learning assembly, not learning radare2. Use GDB/GEF to understand execution; add radare2 later if static analysis of binaries becomes a goal.

---

### Disassembly / Inspection

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| objdump | system (GNU Binutils, Ubuntu 24.04) | Disassemble compiled C to inspect what GCC generates | The standard tool for the "write C, read assembly" loop. Key flags: `objdump -d -M intel` (Intel syntax), `objdump -S -M intel` (interleave source and assembly when compiled with `-g`). Ships with `build-essential`. |

**Critical flag:** Always use `-M intel` with objdump. Without it, output is AT&T syntax — confusing when reading alongside NASM source.

---

### Memory Debugging

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| AddressSanitizer (ASan) | built into GCC 14 | Detect buffer overflows, use-after-free in C exercises | Compile-time instrumentation, ~2x slowdown. Zero installation — it's a GCC flag (`-fsanitize=address`). Essential for the C memory management exercises where writing off the end of an allocation is a common learning mistake. |
| Valgrind | system (3.26.0 latest) | Detect memory leaks, uninitialized reads | Slower (~10-20x) but works on unmodified binaries. Use for `malloc`/`free` exercises where leak detection matters more than speed. |

**Use ASan first:** It's faster and catches more bugs at compile time. Fall back to Valgrind when you need leak detection on an already-built binary.

---

### Testing (for C/assembly integration exercises)

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Unity | latest (vendored header) | Lightweight C test framework for verifying exercise outputs | The Exercism x86-64 track uses Unity for exactly this use case: calling assembly routines from C test harnesses. A single `unity.c` + `unity.h` file vendored into the repo is all it takes. No build system integration needed. |

**Why not a custom main():** Test assertions in a dedicated framework print which check failed and why. `assert()` just aborts. For exercises that verify register values, return values, and memory state, Unity's macros (`TEST_ASSERT_EQUAL_INT`, `TEST_ASSERT_EQUAL_MEMORY`) are more informative.

**Why not Google Test / Catch2:** C++ testing frameworks add a C++ compilation step to what are deliberately C/assembly exercises. Unity is pure C.

---

## Full Installation (WSL2 / Ubuntu 24.04)

```bash
# Core toolchain
sudo apt update
sudo apt install -y build-essential nasm gdb binutils valgrind

# GEF (GDB enhancement)
pip3 install keystone-engine capstone unicorn
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

# Verify versions
nasm --version       # NASM version 2.16.x (apt) or build 3.01 from source
gcc --version        # gcc (Ubuntu) 14.2.0
gdb --version        # GNU gdb 15.x
objdump --version    # GNU objdump 2.42
```

**NASM version note:** Ubuntu 24.04's apt package ships NASM 2.16.x, not 3.01. For this learning project, 2.16.x is fully sufficient — NASM 3.x adds APX extensions not needed for foundational work. Install from apt; do not compile from source.

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Assembler | NASM | GAS | AT&T syntax increases cognitive load; operand order is backward vs Intel manuals |
| Compiler | GCC 14 | Clang 18 | GCC is WSL default; no reason to add second toolchain; CS:APP uses GCC |
| Build system | GNU Make | CMake | CMake abstracts what we're trying to learn (linker, object files, compile flags) |
| Build system | GNU Make | Shell scripts | No incremental builds, no standard targets, less readable |
| Debugger plugin | GEF | pwndbg | pwndbg is exploit-dev focused; GEF is better for general learning |
| Debugger plugin | GEF | PEDA | PEDA is Python 2, frozen, unmaintained |
| Memory tool | ASan | only Valgrind | ASan is 5-10x faster and catches more bugs; Valgrind reserved for leak detection |
| Testing | Unity | custom main() | Unity gives better failure messages; one header to vendor, no dependencies |

---

## Key Decisions

**Syntax consistency:** NASM for source + `objdump -M intel` + `gcc -masm=intel -S` = all assembly output in Intel syntax throughout the project. No context-switching between syntaxes.

**Calling convention:** System V AMD64 ABI only (Linux). This is the convention GCC uses by default on Linux/WSL and what the Exercism track standardizes on. The Microsoft x64 ABI (Windows) is explicitly out of scope.

**No emulators:** All exercises run natively on x86-64 via WSL2. No QEMU, no cross-compilation. This is explicitly stated in PROJECT.md constraints.

---

## Sources

- NASM official site (version 3.01 confirmed): https://www.nasm.us/
- Ubuntu developer docs, GCC 14.2.0 on Ubuntu 24.04: https://documentation.ubuntu.com/ubuntu-for-developers/howto/gcc-setup/
- Exercism x86-64 Assembly track (NASM + Unity + Makefile pattern): https://github.com/exercism/x86-64-assembly
- GEF vs pwndbg 2025 comparison: https://medium.com/@elpepinillo/peda-gef-and-pwndbg-which-gdb-extension-should-you-use-in-2025-67033ddd8459
- CS:APP (x86-64, GCC, -Og flag rationale): https://csapp.cs.cmu.edu/
- Valgrind vs AddressSanitizer comparison: https://undo.io/resources/gdb-watchpoint/a-quick-introduction-to-using-valgrind-and-addresssanitizer/
- GEF official docs: https://hugsy.github.io/gef/
