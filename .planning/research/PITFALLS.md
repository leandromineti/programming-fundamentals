# Domain Pitfalls: x86-64 Assembly + C Self-Study

**Domain:** Low-level programming education (x86-64 assembly + C)
**Researched:** 2026-04-05
**Context:** Personal self-study repository. Windows 11 + WSL2 environment. Learner has high-level language background (Python, etc.) but gap at machine level.

---

## Critical Pitfalls

Mistakes that derail the project, cause rewrites, or kill motivation entirely.

---

### Pitfall 1: Storing Project Files on the Windows Filesystem (`/mnt/c/...`)

**What goes wrong:** WSL2 accesses Windows paths through a network-style 9P protocol bridge. Any file operation that crosses the OS boundary — compilation, linking, `make`, watching for changes — becomes measurably slow. On large builds this becomes disruptive; on small assembly projects it just produces friction that accumulates over weeks.

**Why it happens:** Convenience — the repo is cloned from Windows Explorer or VS Code into `C:\Users\...`, and WSL2 mounts it at `/mnt/c/Users/...`. Everything works, but via the slow path.

**Consequences:** Compile-run cycles feel sluggish. Debugging with GDB on cross-filesystem binaries adds latency. VS Code Remote WSL helps but doesn't eliminate the penalty if files live on the Windows side.

**Prevention:** Clone the repository directly into the WSL2 filesystem: `~/projects/programming-fundamentals` or similar. Access it from Windows Explorer via `\\wsl$\Ubuntu\home\...` if needed (the fast direction). Microsoft's own docs confirm the native Linux path is the correct one for development work.

**Detection:** Run `pwd` inside WSL2 — if it starts with `/mnt/c/`, files are on the wrong side.

**Phase relevance:** Phase 1 (toolchain setup). Must be addressed before any exercises are created.

---

### Pitfall 2: Syntax War — Choosing AT&T Syntax Without a Clear Reason

**What goes wrong:** The learner starts with GAS (GNU Assembler) because it ships with GCC, encounters AT&T syntax (`movq %rax, %rbx`), finds it counter-intuitive (source on left, destination on right; `%` prefixes everywhere; size suffixes appended to mnemonics), and either wastes time fighting the syntax or switches assemblers mid-project, losing continuity.

**Why it happens:** GAS is the default when you type `as` on Linux, and GCC's `-S` flag emits AT&T syntax by default. Beginners follow the path of least resistance without realizing NASM exists and is better suited to learning.

**Consequences:** Cognitive load doubles: learning the instruction set AND decoding cryptic syntax simultaneously. AT&T operand order is opposite to Intel manuals, so official Intel documentation becomes harder to read. Motivation drops.

**Prevention:** Commit to NASM + Intel syntax from day one. NASM is explicitly designed for the Intel syntax that matches official x86-64 documentation. When reading GCC disassembly, use `-masm=intel` flag or configure GDB with `set disassembly-flavor intel`. This keeps syntax consistent across all tools.

**Detection warning sign:** If exercises are written in GAS AT&T syntax and the learner constantly has to "mentally flip" operand order, the wrong choice was made.

**Phase relevance:** Phase 1 (toolchain decision). Non-negotiable early choice — changing assemblers mid-project is disruptive.

---

### Pitfall 3: Stack Misalignment When Calling C Standard Library Functions

**What goes wrong:** The System V AMD64 ABI (Linux) requires the stack to be 16-byte aligned at the point of a `call` instruction. When calling `printf` or any libc function from assembly, the stack must be aligned — failing this causes a segfault that looks completely mysterious (no obvious bad pointer, no obvious logic error).

**Why it happens:** The ABI rule is: `%rsp` must be 16-byte aligned *before* the `call` instruction. After `call` pushes the return address (8 bytes), `%rsp` inside the called function is 8 bytes off a multiple of 16. This means at the `_start` or the start of `main`, `%rsp` is already 16-byte aligned. But any function that `push`es an odd number of 8-byte values before calling another function breaks alignment. Beginners don't track this.

**Consequences:** Segfault on the first libc call. GDB shows the crash inside `printf`'s SSE instructions (which require 16-byte aligned memory). The learner has no idea why their own code seems fine but crashes in library code.

**Prevention:** Establish a mental model early: "Before any `call` to a C function, `%rsp` mod 16 must equal 0." A common fix is to subtract an extra 8 from `%rsp` (or push a dummy register) to achieve alignment when the count of pushes is odd.

**Detection:** GDB crash inside `movaps` (SSE move, requires 16-byte alignment) is the canonical signature of this bug.

**Phase relevance:** Phase 1–2 (calling conventions). Should be introduced the moment any exercise calls a C function.

---

### Pitfall 4: Clobbering Callee-Saved Registers Without Preservation

**What goes wrong:** The System V ABI splits registers into caller-saved (scratch) and callee-saved (preserved). The callee-saved registers are: `rbx`, `rbp`, `r12`–`r15`. Any assembly function that uses these without saving/restoring them corrupts the caller's state. The bug is silent — the crash or wrong value happens elsewhere, far from the actual corruption site.

**Why it happens:** Beginners write assembly functions that freely use all registers (there are 16 of them, why not?) without reading the ABI. The error only manifests when the function is called from C or from another function that relied on a preserved register.

**Consequences:** Heisenbugs. A function works fine when called in isolation but breaks other things when integrated. Very hard to debug without knowing what to look for.

**Prevention:** Introduce the caller-saved / callee-saved distinction explicitly in the first calling convention exercise. Establish a rule: if an assembly function uses `rbx`, `rbp`, or `r12`–`r15`, the first thing it does is `push` them and the last thing is `pop` them.

**Detection:** GDB `info registers` after a suspicious crash will show a callee-saved register with an unexpected value.

**Phase relevance:** Phase 2 (calling conventions and stack frames).

---

### Pitfall 5: GCC Optimization Hiding What the Learner Expects to See

**What goes wrong:** The learner writes a simple C function, compiles it, and examines the assembly with `objdump -d` or Compiler Explorer (godbolt.org). With `-O2` or higher, GCC inlines, reorders, eliminates variables, and replaces loops with SIMD instructions. The assembly looks nothing like the C source. The learner concludes they don't understand assembly, when really they just need `-O0`.

**Why it happens:** Many guides don't mention optimization levels explicitly, or the learner forgets to add the flag.

**Consequences:** Confusion and false incompetence. The learner may spend hours trying to "decode" aggressively optimized output when the goal was to see a straightforward C-to-assembly mapping.

**Prevention:** All C disassembly exercises must use `-O0 -fno-omit-frame-pointer` to preserve frame pointers and produce 1:1 readable output. Godbolt.org should be introduced as the canonical tool for C-to-assembly exploration, with `-O0` as the default and `-O1`/`-O2` introduced *later* specifically to demonstrate what the compiler can do.

**Detection:** If a `for` loop in C produces no loop in the assembly, optimization is transforming the code.

**Phase relevance:** Phase 3 (C-to-assembly bridge). Must be addressed before any disassembly exercises.

---

## Moderate Pitfalls

Mistakes that waste significant time but don't derail the project.

---

### Pitfall 6: Scope Creep — OS Concepts and Syscalls Creeping into Early Phases

**What goes wrong:** Assembly exercises naturally lead to wanting to do real things — print output, read input, allocate memory. The shortest path involves syscalls (`syscall` instruction, `sys_write`, `sys_read`, `mmap`). This pulls in process model, file descriptor concepts, and kernel ABI — all of which are explicitly out of scope for this milestone.

**Why it happens:** "Hello world" in standalone assembly with no libc requires a `sys_write` syscall. It's the simplest possible program, but it introduces OS concepts immediately.

**Prevention:** Use libc from day one for I/O (link with `-lc`, call `printf`/`scanf` from assembly). This keeps exercises focused on registers, instructions, and calling conventions — not kernel interfaces. Defer raw syscall exercises to a future milestone explicitly scoped for OS concepts.

**Detection:** If an exercise contains a `syscall` instruction and the current phase isn't about OS/kernel layer, scope has crept in.

**Phase relevance:** Phase 1–2. Define the exercise boundary explicitly: libc is allowed, raw syscalls are not yet.

---

### Pitfall 7: Using 32-bit Resources and Examples on a 64-bit Target

**What goes wrong:** The internet has enormous amounts of x86 assembly content — most of it from the 2000s–2010s using 32-bit (IA-32) conventions: `eax` instead of `rax`, `esp` instead of `rsp`, `int 0x80` syscalls, `push`/`pop` for arguments. This content is actively misleading for x86-64 work.

**Why it happens:** Search results surface old tutorials. "x86 assembly tutorial" retrieves 32-bit content frequently. The register naming difference (`eax` vs `rax`) is visible but the calling convention difference (stack-passed args vs register-passed args) is not obvious.

**Consequences:** Code that "should work" based on a tutorial doesn't work. Calling conventions are wrong. Syscall mechanism differs. Frame layout differs. Time spent debugging wrong assumptions.

**Prevention:** Every resource referenced in exercises must be explicitly x86-64. Establish a rule: if a tutorial uses `int 0x80` or passes function arguments on the stack left-to-right, it is a 32-bit resource. Use it only for historical context.

**Detection:** Check for `int 0x80` syscall patterns, `push` before function calls for arguments, or register names without the `r` prefix as sole register names.

**Phase relevance:** Phase 1 (toolchain and resources). Vet all reference material upfront.

---

### Pitfall 8: No Feedback Mechanism — Exercises With No Verifiable Output

**What goes wrong:** An exercise that "just runs without crashing" is not a feedback loop. The learner writes code, it compiles, it exits — but did it do the right thing? Without an observable correct output (printed value, computed result, assertion), the learner can't distinguish "correct implementation" from "happens not to crash."

**Why it happens:** Assembly exercises are naturally lower-level — printing a result requires calling `printf` or writing syscall wrappers, which feels like extra work. So exercises get written as "implement this function" with no verification.

**Consequences:** Silent bugs become embedded as "learned patterns." The learner builds false confidence. Errors compound across exercises.

**Prevention:** Every exercise must produce verifiable output — a printed number, a returned value checked by a small C test harness, or a comparison printed with a pass/fail message. The PROJECT.md requirement "tudo deve rodar" should mean "must run AND produce a checkable result."

**Detection:** If the exercise's success criterion is only "no segfault," it lacks feedback.

**Phase relevance:** All phases. Establish this discipline from exercise 1.

---

### Pitfall 9: Debugging Without GDB Habits from Day One

**What goes wrong:** Assembly debugging without GDB means `printf` debugging — inserting print calls to inspect register values. This is both painful (registers aren't directly printable without format wrappers) and teaches nothing about the actual debugging tools. The learner reaches a bug they can't print their way out of and has no idea how to use GDB.

**Why it happens:** GDB has a steep UX curve. TUI mode isn't obvious. Register inspection commands aren't intuitive. Beginners avoid it.

**Consequences:** When real bugs appear (misalignment, wrong register, bad memory access), the learner is helpless. Debugging time explodes on problems that GDB would solve in 30 seconds.

**Prevention:** Introduce GDB in phase 1 with a minimal "starter kit" of five commands: `break`, `run`, `info registers`, `x/16xb $rsp` (examine stack), `si` (step instruction). Build GDB into the standard workflow from the first exercise.

**Detection:** If exercises have no mention of how to debug them, GDB hasn't been introduced.

**Phase relevance:** Phase 1. Must be part of toolchain setup, not an afterthought.

---

## Minor Pitfalls

Friction that slows down individual exercises but doesn't compound.

---

### Pitfall 10: Confusion Between `rax`/`eax`/`ax`/`al` Register Aliases

**What goes wrong:** x86-64 exposes each general-purpose register at four widths: 64-bit (`rax`), 32-bit (`eax`), 16-bit (`ax`), 8-bit (`al`/`ah`). Writing to `eax` zero-extends into `rax` (clears upper 32 bits). Writing to `ax` or `al` does NOT zero-extend. Beginners use the wrong width and get stale high bits.

**Prevention:** Explicitly document the zero-extension rule in phase 1. Make a reference table part of the repository's notes. Use `rax` consistently for 64-bit work and only introduce narrow widths when the exercise specifically needs them.

**Phase relevance:** Phase 1 (register exercises).

---

### Pitfall 11: Forgetting `extern` Declarations When Calling C from Assembly

**What goes wrong:** Calling `printf` from NASM assembly requires declaring it as external: `extern printf`. Omitting this causes a linker error that looks cryptic to beginners (`undefined symbol`, relocation error). The error message doesn't explain the missing `extern`.

**Prevention:** Every exercise template that calls a C function should include the `extern` declarations as boilerplate. Document why they are required.

**Phase relevance:** Phase 1–2 (any exercise calling libc).

---

### Pitfall 12: Red Zone Surprise in Leaf Functions

**What goes wrong:** The System V ABI defines a 128-byte "red zone" below `%rsp` that leaf functions can use as scratch space without adjusting the stack pointer. This sounds convenient but causes hard-to-explain bugs when a signal handler fires during a leaf function (signal handlers don't respect the red zone). For learning purposes, the red zone creates confusion: why does a function work without `sub rsp, N`?

**Prevention:** Teach the red zone as a named concept when it first appears in disassembly output (GCC uses it freely). Frame it explicitly: "GCC leaf functions may omit the stack frame adjustment because of the red zone — here is why that works and when it breaks."

**Phase relevance:** Phase 2 (stack frames and calling conventions).

---

### Pitfall 13: Learning Order Disruption — Jumping to C Before Assembly Mental Model Is Solid

**What goes wrong:** The decision to teach "assembly before C" (captured in PROJECT.md Key Decisions) is sound but requires discipline. The temptation to "just write the exercise in C and look at the assembly" appears immediately. If C is introduced too early, assembly becomes a read-only curiosity rather than something the learner writes fluently.

**Prevention:** Complete at least one full assembly module (registers, arithmetic, control flow, basic stack) before introducing C exercises. The C-to-assembly bridge phase should require reading and modifying disassembly output — not switching back to C when assembly gets hard.

**Phase relevance:** Phase 1–3 boundary. Enforce the sequencing intentionally.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|---|---|---|
| Toolchain Setup | Files on Windows filesystem (`/mnt/c`), wrong assembler choice | Clone repo into WSL2 native fs; commit to NASM |
| Registers and Basic Instructions | AT&T syntax confusion from online resources; 32-bit tutorials | Vet resources; add Intel syntax flag to GDB; use NASM |
| Stack and Calling Conventions | Stack misalignment segfaults; clobbered callee-saved registers; red zone confusion | Explicit ABI reference card in repo; GDB as standard debugger |
| C Exercises | Uninitialized pointers, `scanf` missing `&`, operator precedence with `*` | Use `valgrind` (via WSL) for memory errors from the first C exercise |
| C-to-Assembly Bridge | GCC optimization hiding expected output; AT&T vs Intel syntax in `objdump` | Force `-O0 -fno-omit-frame-pointer`; use `-masm=intel` with objdump |

---

## Sources

- [Top 5 Common Mistakes in Assembly Development](https://moldstud.com/articles/p-top-5-common-mistakes-in-assembly-development-how-to-avoid-them-for-success) — MEDIUM confidence (WebSearch)
- [System V ABI — OSDev Wiki](https://wiki.osdev.org/System_V_ABI) — HIGH confidence (official reference)
- [x86 Calling Conventions — Wikipedia](https://en.wikipedia.org/wiki/X86_calling_conventions) — HIGH confidence (well-maintained, cites ABI spec)
- [Agner Fog: Calling Conventions PDF](https://www.agner.org/optimize/calling_conventions.pdf) — HIGH confidence (authoritative optimization reference)
- [WSL2 Filesystem Performance Issues](https://github.com/microsoft/WSL/issues/4197) — HIGH confidence (official Microsoft WSL issue tracker)
- [Comparing WSL Versions — Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/compare-versions) — HIGH confidence (official Microsoft docs)
- [Linux Assemblers: GAS vs NASM — IBM Developer](https://developer.ibm.com/articles/l-gas-nasm/) — MEDIUM confidence (WebSearch, established source)
- [GCC Optimize Options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html) — HIGH confidence (official GCC docs)
- [Debugging x86-64 Assembly with GDB](https://blog.codingconfessions.com/p/debugging-x86-64-assembly-with-gdb) — MEDIUM confidence (WebSearch)
- [Diagnosing Segfaults in x86 Assembly — Infosec Institute](https://www.infosecinstitute.com/resources/secure-coding/how-to-diagnose-and-locate-segmentation-faults-in-x86-assembly/) — MEDIUM confidence (WebSearch)
- [Common C Pointer/Memory Bugs — GeeksforGeeks](https://www.geeksforgeeks.org/c/common-memory-pointer-related-bug-in-c-programs/) — MEDIUM confidence (WebSearch)
- [Compiler Explorer (godbolt.org)](https://godbolt.org/) — HIGH confidence (official tool)
- [Should you learn C or Assembly first? — Quora community discussion](https://www.quora.com/Should-you-learn-C-or-Assembly-first) — LOW confidence (community opinion, not authoritative)
- [Ask Hackaday: Learn Assembly First, Last, Or Never?](https://hackaday.com/2023/07/14/ask-hackaday-learn-assembly-first-last-or-never/) — LOW confidence (opinion piece)
