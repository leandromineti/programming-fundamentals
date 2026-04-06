<!-- GSD:project-start source:PROJECT.md -->
## Project

**Programming Fundamentals**

Um repositório de estudo pessoal que explora as diferentes camadas de abstração do software, começando pelo hardware e subindo até linguagens de alto nível. Cada tópico contém exercícios executáveis que constroem fundamentos para os tópicos seguintes.

**Core Value:** Entender como software realmente funciona — do registrador ao framework — sendo capaz de rastrear qualquer abstração até sua implementação concreta.

### Constraints

- **Arquitetura**: x86-64 apenas — sem emuladores, exercícios rodam nativamente
- **Toolchain**: Ferramentas open-source (gcc, nasm ou gas) via WSL
- **Formato**: Todo exercício deve compilar e executar com instruções claras
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Assembler
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| NASM | 3.01 (stable, 2025-10-11) | x86-64 assembly source files | Intel syntax is how Intel documents its own ISA. Every datasheet, manual, and disassembler output readable with `-M intel` flag uses this syntax. Learning AT&T (GAS) means reading `movq %rax, %rbx` instead of `mov rbx, rax` — backward operand order adds cognitive load on top of an already demanding domain. |
### Compiler
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GCC | 14.2.0 (Ubuntu 24.04 default) | Compile C exercises, generate disassembly for inspection | The reference compiler for systems-level C. CS:APP (the canonical book for this domain) uses GCC specifically. The `-Og` optimization flag was added to GCC precisely for the edit-compile-debug cycle in learning contexts — it produces assembly that maps closely to source without optimizing away the structures being studied. |
- `-g` — include DWARF debug symbols (needed for GDB source-level stepping)
- `-O0` — for exercises focused on exact memory layout (no transformations)
- `-Og` — for exercises inspecting compiler output (minimal optimization, debuggable)
- `-fno-omit-frame-pointer` — preserve `rbp` as frame pointer; makes stack frames readable and matches calling convention exercises
- `-masm=intel` — emit GCC disassembly in Intel syntax, matching NASM notation
### Build System
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GNU Make | system (Ubuntu 24.04: 4.3+) | Build, run, and clean individual exercises | A Makefile is the right level of complexity here: one file, explicit rules, no abstraction between "what runs" and "what you read." This is a learning repo — the build script is itself educational. Each exercise directory gets its own `Makefile` that teaches dependency chains. |
### Debugger
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GDB | system (Ubuntu 24.04: 15.x) | Step through assembly instruction-by-instruction, inspect registers and memory | The canonical debugger for x86-64 on Linux. Runs natively in WSL2. TUI mode (`gdb -tui`) shows source and assembly side-by-side. |
| GEF | latest (pip install) | GDB enhancement — register panel, memory display, stack visualization | Vanilla GDB output is dense and hard to read. GEF renders a structured panel after each step showing all registers, their deltas, and the next 5 instructions. For a learner, seeing `rsp` change value after a `push` in a colored diff panel is the difference between understanding and confusion. |
### Disassembly / Inspection
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| objdump | system (GNU Binutils, Ubuntu 24.04) | Disassemble compiled C to inspect what GCC generates | The standard tool for the "write C, read assembly" loop. Key flags: `objdump -d -M intel` (Intel syntax), `objdump -S -M intel` (interleave source and assembly when compiled with `-g`). Ships with `build-essential`. |
### Memory Debugging
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| AddressSanitizer (ASan) | built into GCC 14 | Detect buffer overflows, use-after-free in C exercises | Compile-time instrumentation, ~2x slowdown. Zero installation — it's a GCC flag (`-fsanitize=address`). Essential for the C memory management exercises where writing off the end of an allocation is a common learning mistake. |
| Valgrind | system (3.26.0 latest) | Detect memory leaks, uninitialized reads | Slower (~10-20x) but works on unmodified binaries. Use for `malloc`/`free` exercises where leak detection matters more than speed. |
### Testing (for C/assembly integration exercises)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Unity | latest (vendored header) | Lightweight C test framework for verifying exercise outputs | The Exercism x86-64 track uses Unity for exactly this use case: calling assembly routines from C test harnesses. A single `unity.c` + `unity.h` file vendored into the repo is all it takes. No build system integration needed. |
## Full Installation (WSL2 / Ubuntu 24.04)
# Core toolchain
# GEF (GDB enhancement)
# Verify versions
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
## Key Decisions
## Sources
- NASM official site (version 3.01 confirmed): https://www.nasm.us/
- Ubuntu developer docs, GCC 14.2.0 on Ubuntu 24.04: https://documentation.ubuntu.com/ubuntu-for-developers/howto/gcc-setup/
- Exercism x86-64 Assembly track (NASM + Unity + Makefile pattern): https://github.com/exercism/x86-64-assembly
- GEF vs pwndbg 2025 comparison: https://medium.com/@elpepinillo/peda-gef-and-pwndbg-which-gdb-extension-should-you-use-in-2025-67033ddd8459
- CS:APP (x86-64, GCC, -Og flag rationale): https://csapp.cs.cmu.edu/
- Valgrind vs AddressSanitizer comparison: https://undo.io/resources/gdb-watchpoint/a-quick-introduction-to-using-valgrind-and-addresssanitizer/
- GEF official docs: https://hugsy.github.io/gef/
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, or `.github/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
