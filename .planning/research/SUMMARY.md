# Project Research Summary

**Project:** programming-fundamentals
**Domain:** Self-study exercise repository -- x86-64 assembly and C
**Researched:** 2026-04-05
**Confidence:** HIGH

## Executive Summary

This is a personal study repository designed to fill machine-level knowledge gaps for a developer with a high-level language background. The goal -- tracing any software abstraction to its concrete hardware implementation -- is well-served by a disciplined assembly-first curriculum that culminates in reading compiler-generated disassembly of C code. Research across five university courses (CS:APP, Stanford CS107, Harvard CS61, UMD CMSC216, USC CS356) confirms strong consensus on topic sequencing: registers before memory, memory before stack, stack before calling conventions, calling conventions before C, and C before bridging exercises. This ordering is non-negotiable -- each layer is the vocabulary for the next.

The recommended approach is a 5-module structure with NASM (Intel syntax), GCC, GNU Make, and GDB/GEF running natively in WSL2. The entire toolchain is available via apt on Ubuntu 24.04 in WSL2. Exercises follow the diff-expected-actual verification pattern, which requires no testing framework and keeps the build system readable as a learning artifact. The project is deliberately narrow in scope: x86-64 only, integer arithmetic only, libc for I/O (no raw syscalls), no emulation.

The single most dangerous risk is a WSL2 filesystem mistake at setup: if the repository lives on the Windows side (/mnt/c/...), all toolchain operations run through a slow 9P filesystem bridge and the developer experience degrades persistently. The second most consequential risk is the stack alignment trap -- a segfault inside printf SSE code that has nothing obviously wrong in the assembly source -- which must be taught explicitly at the first exercise that calls a libc function. Both risks have straightforward preventions but must be addressed at the start, not after they surface.

## Key Findings

### Recommended Stack

The toolchain is entirely standard-library, zero installation friction beyond apt: NASM 2.16.x (assembler), GCC 14.2.0 (C compiler + disassembly), GNU Make 4.3 (build system), GDB 15.x + GEF (debugger), objdump (disassembly inspection), ASan + Valgrind (memory debugging). All run natively in WSL2 on Ubuntu 24.04. NASM Intel syntax is the right choice because it matches the Intel ISA documentation, Compiler Explorer Intel output, and the majority of learning repositories; AT&T syntax adds backward operand order on top of an already demanding domain.

A critical cross-cutting discipline applies to every tool that produces assembly output: Intel syntax everywhere. NASM writes it natively; GDB needs set-disassembly-flavor-intel; objdump needs -M intel; GCC -S needs -masm=intel. Establishing this consistency in the toolchain setup phase prevents a persistent cognitive context-switch throughout the project.

**Core technologies:**
- NASM 2.16.x: primary assembler -- Intel syntax matches official x86-64 documentation
- GCC 14.2.0: C compiler and disassembly source -- -Og / -O0 -fno-omit-frame-pointer for readable output
- GNU Make: per-exercise build system -- the Makefile itself is a learning artifact
- GDB + GEF: debugger -- GEF colored register-delta panel is essential for tracking rsp changes
- objdump (-d -S -M intel): disassembly inspection -- the primary C-to-assembly workflow tool
- ASan (GCC built-in): memory error detection for C exercises -- zero installation, compile-time flag
- Valgrind: heap leak detection -- slower than ASan, reserved for explicit leak-check exercises

### Expected Features

All active requirements from PROJECT.md are covered. The table-stakes list maps directly onto the 5-module structure. The differentiator exercises (jump table disassembly, lea as arithmetic, objdump annotation workflow, writing assembly callable from C) provide high insight-per-hour value for a developer with a high-level background and belong in the later phases.

**Must have (table stakes):**
- Registers: naming, widths (rax/eax/ax/al), caller-saved vs callee-saved split
- Data movement (mov), integer arithmetic (add, sub, imul, idiv with cqo)
- Flags register and conditional execution (cmp, test, jcc family)
- Control flow: branches and loops -- first programs with real logic
- Memory addressing modes: [rax + rcx*4 + offset] -- direct connection to pointer arithmetic
- Stack mechanics: push, pop, rsp as a register before introducing call/ret
- System V AMD64 ABI: rdi/rsi/rdx/rcx/r8/r9 for args, rax for return, 16-byte alignment rule
- Function prologues and epilogues: push rbp / mov rbp,rsp / pop rbp / ret
- C data types and sizes: sizeof, twos complement, char/int/long/pointer widths on x86-64
- C pointers: declaration, dereferencing, address-of -- confirmed by the assembly model
- Pointer arithmetic -- confirmed by [rax + rcx*N] addressing mode
- C structs in memory: field offsets, padding rules
- malloc/free: calling convention + pointer result in rax
- Reading C disassembly: gcc -S -O0, objdump -d -S -M intel

**Should have (differentiators):**
- lea as general-purpose multiply-by-constant arithmetic (not just address calculation)
- Switch-statement disassembly: sparse vs dense, jump table pattern
- Stack layout diagram exercise: draw the frame from actual GDB memory output
- Write assembly callable from C: validates complete ABI mastery end-to-end
- Call printf from assembly: 16-byte alignment trap as the key learning moment
- objdump annotation workflow: transferable skill for profiling and security work
- Struct padding and __attribute__((packed)): connects declaration to memory bytes
- Loop unrolling: same loop under -O0 vs -O2 -- see what the compiler actually does

**Defer to future milestones:**
- Recursion in assembly (write in C first, read its disassembly only)
- Handwritten memory allocator (CS:APP malloc lab -- belongs after foundational memory)
- SSE/AVX SIMD and floating-point (x87, XMM registers)
- Raw syscalls and OS interaction (syscall instruction, kernel ABI)
- Inline assembly (asm volatile with constraints)
- Linker scripts and ELF internals

### Architecture Approach

A flat 5-module hierarchy with numeric prefixes (01-registers/, 02-memory/ ... 05-c-meets-assembly/) and per-exercise subdirectories, each self-contained with its own Makefile, stub source file, expected output, and README. A root Makefile provides check-all (tolerates per-exercise failures, prints PASS/FAIL tallies) and clean-all. Solutions live in a parallel solutions/ tree, never imported by exercise Makefiles. Verification is diff expected.txt actual.txt -- no test framework dependency. This is the pattern used by rustlings, exercism x86-64, and ALX low-level programming repositories.

**Major components:**
1. Root Makefile -- recursive build-all, check-all, clean-all over all modules
2. Module directory (NN-topic/) + module README.md -- groups exercises, states learning objectives and references
3. Exercise directory (NN-name/) -- single self-contained problem: stub source, expected.txt, Makefile, README
4. solutions/ tree -- reference implementations at the same path structure, never a build target
5. toolchain.md -- WSL2 setup instructions: one place for install commands and Intel syntax configuration

### Critical Pitfalls

1. **Files on Windows filesystem (/mnt/c/...)** -- Clone into WSL2 native filesystem (~/projects/...) before creating any exercises. Detect with pwd in WSL2 terminal; any path starting with /mnt/c/ is wrong. This is irreversible without re-cloning.

2. **Stack misalignment when calling libc** -- At the first exercise calling printf, teach explicitly: rsp must be 16-byte aligned before call. A segfault inside movaps in GDB is the signature. Add sub rsp,8 or an extra push when odd pushes precede the call. This must be part of the exercise README, not a footnote.

3. **GCC optimization hiding expected output** -- All C disassembly exercises use -O0 -fno-omit-frame-pointer. Introduce -O1/-O2 only in exercises specifically about compiler transformation. A for loop producing no loop in assembly means optimization is running.

4. **AT&T syntax from search results and old tutorials** -- Every resource linked in exercise READMEs must be verified as x86-64. Detect wrong resources by: int 0x80 syscall patterns, stack-passed arguments to functions, or no r-prefix register names (eax as sole register). Use only for historical context.

5. **Exercises with no verifiable output** -- Every exercise must produce checkable stdout or a C test harness result. Compiles-and-does-not-segfault is not a success criterion. Establish this from exercise 1.

## Implications for Roadmap

Based on research, the module dependencies encode a strict ordering. No module can be meaningfully understood without the one before it. The 5-phase structure below maps directly to the 5 modules identified in the architecture research and reflects the consensus ordering from all university curricula reviewed.

### Phase 1: Toolchain + Registers + Basic Instructions

**Rationale:** Everything else requires the toolchain to be correctly configured and registers to be the learner's fluent vocabulary. Toolchain mistakes (filesystem location, syntax inconsistency) become permanent friction if not fixed first. The register model (naming, widths, caller/callee-saved split) is the primitive of all subsequent work.

**Delivers:** Working WSL2 toolchain with Intel syntax throughout; GDB starter workflow established; exercises covering register model, data movement, arithmetic, flags, and control flow.

**Addresses:** Registers and naming, data movement, integer arithmetic, flags register, control flow (branches and loops) from table stakes. Also establishes the objdump annotation habit as a differentiator from day one.

**Avoids:** Windows filesystem trap (clone into WSL2 native fs); AT&T syntax confusion (NASM + Intel flags configured immediately); debugging helplessness (GDB five-command starter kit introduced in exercise 1).

### Phase 2: Memory and Addressing Modes

**Rationale:** Registers without memory access are incomplete. Memory addressing modes ([rax + rcx*4 + offset]) are the direct precursor to understanding pointer arithmetic in C. This phase must precede the stack because the stack is just memory accessed through rsp.

**Delivers:** Exercises covering .data/.bss sections, load/store, and the full addressing mode syntax. Learner can read and write memory operands fluently.

**Addresses:** Memory addressing modes, data sections, the connection between assembly operands and C pointer expressions.

**Avoids:** Jumping to C too early (enforce assembly-only until Phase 4); exercises that run without printing a checkable result.

### Phase 3: Stack, Calling Conventions, and Function Structure

**Rationale:** The stack is the most conceptually dense topic and the direct prerequisite for any mixed C/assembly work. The System V AMD64 ABI calling convention must be taught explicitly -- it is the seam between assembly and all C code. This phase ends with the learner able to write correctly structured, ABI-compliant assembly functions.

**Delivers:** Exercises covering push/pop, call/ret, stack frame layout, the System V ABI register assignments, 16-byte alignment rule, callee-saved register preservation. Capstone: write an assembly function callable from C and call printf from assembly.

**Addresses:** Stack mechanics, calling conventions, function prologues/epilogues, the lea-as-arithmetic differentiator, stack layout diagram exercise.

**Avoids:** Stack misalignment segfaults (explicit 16-byte alignment rule in every calling-convention exercise README); clobbered callee-saved registers (ABI reference card in module README); red zone confusion (named and explained when it appears in GCC output).

### Phase 4: C Fundamentals

**Rationale:** Now that the learner can read and write x86-64 fluently, C data types and pointer operations are confirmed by the assembly model already understood. Pointers are mov rax from memory. Pointer arithmetic is the [rax + rcx*4] addressing mode. Structs are field offsets. This ordering makes C feel like a higher notation for operations already known.

**Delivers:** Exercises covering C data types and sizeof, pointers (declaration, dereferencing, address-of), pointer arithmetic, structs and field offsets, struct padding, malloc/free.

**Addresses:** All C-layer table stakes from the features research. Uses ASan and Valgrind from the first C exercise.

**Avoids:** Uninitialized pointer bugs silently accepted (Valgrind from exercise 1); learning order disruption (no switching back to assembly shortcuts when C gets hard).

### Phase 5: C Meets Assembly (Bridge Exercises)

**Rationale:** Terminal phase integrating all prior knowledge. The payoff for the entire project. Learner reads disassembly of C programs they understand, annotates it, writes assembly called from C, and calls C from assembly. Compiler Explorer (godbolt.org) introduced here for interactive exploration.

**Delivers:** Read C disassembly exercises (gcc -S -O0 then -O1/-O2 comparison); write assembly routines callable from C main; call libc functions from pure assembly; objdump annotation workflow as a reusable skill. Capstone: switch-statement disassembly (jump table) and loop unrolling under -O2.

**Addresses:** All bridge/capstone features. Validates calling convention mastery end-to-end. Introduces Compiler Explorer.

**Avoids:** Optimization hiding (force -O0 in reading exercises; introduce optimized output only in explicit comparison exercises).

### Phase Ordering Rationale

- Registers before memory: registers are the primitive; load/store instructions require knowing what a register is.
- Memory before stack: the stack is a region of memory; rsp is a register pointing into memory. Phase 2 vocabulary is required to explain Phase 3.
- Stack/calling conventions before C: the ABI is the contract between C and assembly. Writing C without knowing this contract produces mystery when inspecting disassembly.
- C fundamentals before bridge: reading pointer arithmetic in disassembly requires knowing what the C source was doing. Without Phase 4, Phase 5 is uninterpretable noise.
- Phases 3 and 4 can be developed in parallel as content creation, but Phase 3 must be taught to the learner before Phase 5.

### Research Flags

Phases with well-documented patterns (can proceed without additional research):
- **Phase 1 (Toolchain + Registers):** Fully documented in official sources. NASM docs, GCC docs, Ubuntu 24.04 package versions all verified. GDB/GEF installation steps confirmed.
- **Phase 2 (Memory):** Standard x86-64 content, multiple high-confidence academic syllabi confirm scope and exercises.
- **Phase 3 (Stack + Calling Conventions):** Highly documented. System V ABI spec is authoritative; CS:APP Chapter 3 covers this exactly; stack alignment trap is well-characterized.
- **Phase 4 (C Fundamentals):** Standard C content. Stanford CS107 and CS:APP both cover this scope in detail.
- **Phase 5 (Bridge):** Well-documented via CS:APP labs, Harvard CS61, Compiler Explorer workflow. No additional research needed.

No phases require deeper research before planning. This domain has exceptional documentation quality from multiple university courses.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All versions verified via official sources; Ubuntu 24.04 package availability confirmed; NASM 2.16.x vs 3.01 version note documented |
| Features | HIGH | Sourced from 5+ university syllabi (CS:APP, Stanford CS107, Harvard CS61, UMD CMSC216, USC CS356); strong consensus on scope and ordering |
| Architecture | MEDIUM | Derived from real repositories (rustlings, exercism x86-64, dtg-lucifer/x86_64-asm-101, ALX); directory internals inferred rather than read directly |
| Pitfalls | HIGH | Stack alignment and filesystem pitfalls sourced from official Microsoft WSL docs, System V ABI spec, and Agner Fog calling conventions reference |

**Overall confidence:** HIGH

### Gaps to Address

- **Exercise count per module:** Research identifies the right topics but not how many exercises each topic warrants. Decide during roadmap phase: aim for 2-4 exercises per topic, each with a single learning focus.
- **GDB tutorial integration:** Research is clear that GDB must be introduced in Phase 1, but the exact format (standalone exercise vs. debugging section in each README) is not prescribed. Decide during planning.
- **Phase 5 test harness format:** Function-level tests in Phase 5 may need a purpose-written harness.c rather than stdout diff. The exact harness interface (print PASS/FAIL vs. return exit code) should be standardized before writing Phase 5 exercises.
- **solutions/ discipline:** How solutions are added (alongside exercise creation vs. after attempting) is a personal workflow choice not addressed by research. Establish this convention in the root README before starting exercises.

## Sources

### Primary (HIGH confidence)

- CS:APP (Bryant and O'Hallaron), Chapter 3 -- canonical x86-64 + C curriculum reference: https://csapp.cs.cmu.edu/
- Stanford CS107 Winter 2026 calendar -- topic sequencing and scope: https://web.stanford.edu/class/archive/cs/cs107/cs107.1262/calendar
- Harvard CS61 Assembly Exercises -- 23-exercise progression: https://cs61.seas.harvard.edu/site/2023/AsmEx/
- System V AMD64 ABI -- OSDev Wiki: https://wiki.osdev.org/System_V_ABI
- Agner Fog Calling Conventions PDF: https://www.agner.org/optimize/calling_conventions.pdf
- Microsoft WSL docs on filesystem performance: https://learn.microsoft.com/en-us/windows/wsl/compare-versions
- Ubuntu developer docs, GCC 14.2.0 setup: https://documentation.ubuntu.com/ubuntu-for-developers/howto/gcc-setup/
- GCC Optimize Options (official): https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
- GEF official docs: https://hugsy.github.io/gef/
- Exercism x86-64 Assembly track (NASM + Makefile): https://github.com/exercism/x86-64-assembly
- GNU Make recursion (official): https://www.gnu.org/software/make/manual/html_node/Recursion.html
- NASM official site: https://www.nasm.us/

### Secondary (MEDIUM confidence)

- UMD CMSC216 syllabus: https://www.cs.umd.edu/~profk/216/syllabus.html
- USC CS356 syllabus: https://usc-cs356.github.io/syllabus.html
- Nayuki x86 assembly introduction (15-topic progression): https://www.nayuki.io/page/a-fundamental-introduction-to-x86-assembly-programming
- dtg-lucifer/x86_64-asm-101 (numeric prefix pattern): https://github.com/dtg-lucifer/x86_64-asm-101
- ALX low-level-programming (hexadecimal prefix pattern): https://github.com/khalid1sey/alx-low_level_programming
- GEF vs pwndbg 2025 comparison: https://medium.com/@elpepinillo/peda-gef-and-pwndbg-which-gdb-extension-should-you-use-in-2025-67033ddd8459
- Stack alignment SIGSEGV analysis: https://sqlpey.com/assembly/sigsegv-stack-alignment-x86-64/
- Valgrind vs AddressSanitizer comparison: https://undo.io/resources/gdb-watchpoint/a-quick-introduction-to-using-valgrind-and-addresssanitizer/

### Tertiary (LOW confidence)

- Community opinions on assembly-first vs C-first learning order -- used only to confirm the assembly-first decision already made in PROJECT.md; not used for technical decisions

---
*Research completed: 2026-04-05*
*Ready for roadmap: yes*
