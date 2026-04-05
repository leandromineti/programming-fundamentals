# Feature Landscape

**Domain:** Programming fundamentals education — x86-64 assembly + C
**Researched:** 2026-04-05
**Scope:** Personal study repository; assembly-first progression to reading C disassembly

---

## Table Stakes

Features (topics and exercise types) that every credible assembly + C fundamentals curriculum covers.
Missing any of these creates a curriculum with visible gaps.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Register model and naming | Registers are the atomic unit of all x86-64 work; nothing else makes sense without this | Low | Cover the full 64/32/16/8-bit naming (rax/eax/ax/al); caller-saved vs callee-saved split is critical |
| Data movement instructions | `mov`, immediate vs register vs memory operands — the single most-used instruction class | Low | AT&T vs Intel syntax choice must be made early; NASM uses Intel, GAS uses AT&T |
| Integer arithmetic (`add`, `sub`, `imul`, `idiv`) | Every non-trivial program does arithmetic; also demonstrates flags side-effects | Low | `idiv` is often a surprise — requires `cqo` sign-extend setup |
| Flags register and conditional execution | Required for any control flow (jumps, comparisons) | Low-Med | `cmp`, `test`, then the `jcc` family |
| Control flow: branches and jumps | Conditionals and loops in assembly — the first exercise where assembly feels like "real programming" | Medium | `jmp`, `je`, `jne`, `jl`, `jg` etc.; direct mapping to C `if`/`while` |
| Memory addressing modes | `[rax]`, `[rax + 8]`, `[rax + rcx*4 + offset]` — essential for arrays and structs | Medium | The full `offset(base, index, scale)` form; connecting to pointer arithmetic in C |
| The stack: `push`, `pop`, `rsp` | Required before any function calls can be explained; also where local variables live | Medium | Manual stack manipulation exercises before introducing `call`/`ret` |
| Calling conventions (System V AMD64 ABI) | The bridge between assembly and C; required to call `printf`, `malloc`, any libc function | Medium-High | rdi, rsi, rdx, rcx, r8, r9 for args; rax for return; callee-saved: rbx, rbp, r12-r15; 16-byte stack alignment before `call` |
| Function prologues and epilogues | Every non-trivial exercise needs a properly structured function | Medium | `push rbp` / `mov rbp, rsp` / `pop rbp` / `ret` pattern; why rbp is used |
| C data types and sizes | sizeof(int), sizeof(pointer), two's complement; connects C declarations to assembly operand sizes | Low | `char`=1, `short`=2, `int`=4, `long`/pointer=8 on x86-64 Linux |
| C pointers: declaration, dereferencing, address-of | Pointers are where most C learners get stuck; assembly perspective demystifies them | Medium | The assembly `mov rax, [rbx]` is exactly what `*p` does; `lea` is address-of |
| Pointer arithmetic | Array indexing, stride, `p + n` advances by `n * sizeof(*p)` | Medium | The multiply-by-size rule; connection to `[rax + rcx*4]` addressing mode |
| C structs in memory | Struct layout, field offsets, padding rules | Medium | Read struct fields via `[rbp - N]` or `[rdi + offset]` from assembly |
| Dynamic memory allocation (`malloc`/`free`) | Manual heap management is the signature challenge of C | Medium | Calling `malloc` from assembly; pointer result in rax; `free` takes pointer in rdi |
| Compiling C and reading the output | The payoff exercise: write C, compile with `gcc -S` or `objdump -d`, read what the compiler generated | Medium-High | `-O0` first (no optimization), then `-O1` or `-O2` to see transformations; `gcc -S -O0` vs `gcc -S -O1` diff |
| GDB basics for assembly debugging | Students need a way to inspect registers, step through instructions, examine memory | Medium | `layout asm`, `layout regs`, `break`, `si` (step instruction), `x/` examine memory |

---

## Differentiators

Topics and exercises that are uncommon in beginner curricula but provide high insight-per-hour value, especially for someone with a high-level language background who wants to understand the machine.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| `lea` as general-purpose arithmetic | Shows that `lea rax, [rbx + rcx*4 + 5]` is used by compilers for fast multiply-by-constant, not just address calculation | Low-Med | CS:APP covers this; high-level devs are often surprised compilers repurpose `lea` this way |
| Switch-statement disassembly (jump tables) | Compilers turn dense switch statements into jump tables — a concrete example of compiler optimization | Medium | Compare sparse vs dense switch; `jmp [rax*8 + table]` pattern; high insight payoff |
| Loop unrolling and compiler optimization flags | Running the same C loop under `-O0` vs `-O2`; seeing automatic unrolling and vectorization hints | Medium | Demonstrates why "writing C" and "writing assembly" are not the same performance-wise |
| Stack layout diagram exercise | Drawing the full stack frame — return address, saved rbp, local variables, arguments — with actual addresses from GDB | Medium | The visual "stack diagram from GDB output" exercise anchors everything; very effective for spatial learners |
| Writing a function in pure assembly that C can call | Defines a `.globl` symbol, follows ABI, links with C `main()` | Medium-High | End-to-end exercise showing the seam between the two languages; validates understanding of calling conventions |
| Calling a C library function from assembly | Call `printf` or `write` from a pure `.asm` file — forces correct ABI usage | Medium-High | Classic "hello world from assembly using libc" exercise; 16-byte alignment trap is the key learning moment |
| Two's complement arithmetic exercises | Overflow, sign extension (`movsx` vs `movzx`), signed vs unsigned comparison (`jl` vs `jb`) | Medium | Explains why `-1 > 2` is false when signed but `0xFFFF... > 2` is true unsigned |
| `objdump` annotation workflow | A reusable workflow: write C, compile, `objdump -d -S`, annotate the output by hand | Low-Med | Builds the skill used in profiling, reverse engineering, and security work; very transferable |
| Struct padding and `__attribute__((packed))` | Show struct with vs without padding; rewrite assembly to match; explain cache line implications | Medium | Connects C struct layout to actual memory bytes; `gcc -O0 -g` + GDB memory inspection |

---

## Anti-Features

Topics to explicitly NOT include in the first milestone. Including them would bloat scope, reduce exercise density on core concepts, or require prerequisites not yet established.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| x87 floating-point unit (`fld`, `fstp`, FPU stack) | Legacy 8-register stack-based FPU; not what gcc generates in modern code; high cognitive overhead for zero modern payoff | If floats are needed for an exercise, defer to a future milestone with SSE/XMM registers |
| SSE/AVX SIMD intrinsics | Valuable for performance work, but requires understanding scalar execution first; not what beginners see in typical C disassembly | Mention SIMD registers exist; defer vectorization to a dedicated milestone |
| Inline assembly in C (`asm volatile`) | Mix of syntaxes, input/output operand constraints, clobber lists — far more complex than it looks; beginners cannot debug it | Instead, write separate `.asm` files linked with C; clean seam, debuggable |
| Operating system syscalls directly | `syscall` instruction requires knowing kernel ABI (rax=syscall number, etc.); entirely separate convention from libc C ABI; scope-expands into OS concepts | Out of scope per PROJECT.md — reserved for a future OS milestone; use `printf`/`write` via libc instead |
| Process, signals, threading | OS concepts explicitly deferred in PROJECT.md | Future milestone |
| Linker scripts and ELF internals | Important for embedded/OS work but requires kernel concepts; not needed to understand C disassembly | A future milestone topic |
| Recursion in assembly | Recursion exercises are conceptually valid but require solid calling-convention mastery first; a common teaching trap — the concept is simple but the assembly implementation debugging is very painful for beginners | Implement recursion in C first, then read its disassembly; write recursive assembly only after completing all calling convention exercises |
| Handwritten memory allocator | CS:APP has a heap allocator lab (malloc lab) but it belongs after foundational memory exercises; a full allocator requires free-list data structures, coalescing, metadata management | Stanford CS107 places this in week 8 of a 10-week course — clearly not first-milestone material; use `malloc`/`free` as black boxes first |
| Floating-point / complex number exercises | Requires XMM registers, `movsd`/`movss`, entirely different instruction subset | Strictly defer; use integer exercises only in first milestone |
| Makefiles and build system complexity | Tool friction creates early dropouts; focus should stay on concepts | Use a single `Makefile` or compile commands in comments; no multi-target build system |

---

## Feature Dependencies

The correct ordering — each topic depends on its predecessors being solid.

```
Register model and naming
  └── Data movement instructions (mov)
        ├── Integer arithmetic (add, sub, imul)
        │     └── Flags register and conditionals
        │           └── Control flow (jumps, branches, loops)
        │                 └── [C connection: if/while/for disassembly]
        └── Memory addressing modes
              ├── The stack (push, pop, rsp)
              │     └── Calling conventions (System V ABI)
              │           ├── Function prologues and epilogues
              │           │     ├── [Write assembly callable from C]
              │           │     └── [Call C libc from assembly]
              │           └── Stack layout diagram exercise
              └── [C connection: pointer arithmetic, struct field offsets]

C data types and sizes
  └── C pointers (declaration, dereferencing, address-of)
        ├── Pointer arithmetic
        │     └── C structs in memory
        │           └── Struct padding
        └── Dynamic memory allocation (malloc/free)

GDB basics [parallel track — needed from first memory exercise onward]

Compiling C + reading output [capstone — requires all of the above]
  ├── objdump annotation workflow
  ├── Switch-statement disassembly
  └── Loop unrolling / compiler flags comparison
```

---

## MVP Recommendation

The minimum set that achieves the project's stated core value ("entender como software realmente funciona — do registrador ao framework") and satisfies all active requirements from PROJECT.md:

**Prioritize (assembly layer):**
1. Registers, data movement, basic arithmetic — the alphabet
2. Flags + control flow — first programs that do something real
3. Memory addressing modes — connects to C pointers
4. Stack mechanics + calling conventions — the essential bridge
5. Function prologues/epilogues — write real, callable functions

**Prioritize (C layer):**
6. C data types, sizeof, two's complement
7. Pointers and dereferencing — confirmed by the assembly model
8. Pointer arithmetic — confirmed by addressing modes
9. C structs — confirmed by field-offset addressing
10. malloc/free — first touch of heap

**Capstone (bridge exercises):**
11. Read disassembly of C programs (`gcc -S`, `objdump -d -S`)
12. Write assembly callable from C (validates ABI mastery)
13. Call `printf` from assembly (validates 16-byte alignment and arg passing)

**Defer to future milestones:**
- Recursion in assembly (do in C first, read its disassembly only)
- Heap allocator implementation
- SIMD/floating-point
- Syscalls and OS interaction
- Inline assembly

---

## Sources

- CS:APP (Bryant & O'Hallaron), Chapter 3 overview: https://csapp.cs.cmu.edu/ — HIGH confidence
- CS:APP Chapter 3 preview (x86-64 machine-level representation): http://csapp.cs.cmu.edu/3e/pieces/preface3e.pdf — HIGH confidence
- Stanford CS107 weekly calendar (Winter 2026): https://web.stanford.edu/class/archive/cs/cs107/cs107.1262/calendar — HIGH confidence
- Harvard CS61 Assembly Exercises (23 exercise sets, progression documented): https://cs61.seas.harvard.edu/site/2023/AsmEx/ — HIGH confidence
- CMSC216 (University of Maryland) syllabus: https://www.cs.umd.edu/~profk/216/syllabus.html — HIGH confidence
- USC CS356 Computer Systems syllabus: https://usc-cs356.github.io/syllabus.html — HIGH confidence
- Cornell CS 3410 Spring 2026 syllabus: https://www.cs.cornell.edu/courses/cs3410/2026sp/course/syllabus.html — MEDIUM confidence
- "Programming from the Ground Up" (Bartlett), table of contents: https://www.cs.princeton.edu/courses/archive/spr08/cos217/reading/ProgrammingGroundUp-1-0-lettersize.pdf — HIGH confidence
- Nayuki x86 assembly introduction (15-topic progression): https://www.nayuki.io/page/a-fundamental-introduction-to-x86-assembly-programming — MEDIUM confidence
- x86-64 calling conventions (Brown CS0300): https://cs.brown.edu/courses/csci0300/2021/notes/l07.html — HIGH confidence
- Stack alignment SIGSEGV analysis: https://sqlpey.com/assembly/sigsegv-stack-alignment-x86-64/ — MEDIUM confidence
- Calling printf from x86-64 assembly (alignment pitfall documented): https://linuxvox.com/blog/calling-printf-in-x86-64-using-gnu-assembler/ — MEDIUM confidence
