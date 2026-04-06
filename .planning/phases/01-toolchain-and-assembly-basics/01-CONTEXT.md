# Phase 1: Toolchain and Assembly Basics - Context

**Gathered:** 2026-04-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Configure the WSL2 development environment (NASM, GCC, Make, GDB+GEF) and deliver executable x86-64 assembly exercises covering registers, arithmetic, control flow, and memory addressing modes. Each exercise compiles, runs, and self-verifies with `make check`.

</domain>

<decisions>
## Implementation Decisions

### Output Method
- **D-01:** All assembly programs produce verifiable output via Linux syscalls (sys_write to stdout, sys_exit) — no libc dependency
- **D-02:** A shared `print_uint64` helper routine is provided in `lib/` for exercises that need to print numeric results (e.g., arithmetic exercises). Students include it; the conversion logic is not the focus of early exercises
- **D-03:** Text strings are defined in `section .data` with labels using `db` — standard NASM pattern

### Directory Structure
- **D-04:** One directory per exercise, grouped under topic directories: `01-registers/asm-01-mov/`, `02-flow-control/asm-03-conditionals/`, `03-memory/asm-05-data-bss/`, etc.
- **D-05:** Shared helpers live in `lib/` at the project root (e.g., `lib/print_uint64.asm`). Exercise Makefiles reference `../../lib/` or equivalent relative path
- **D-06:** The main source file in each exercise directory is always named `main.asm` — the directory name carries the exercise identity

### Exercise Format
- **D-07:** Exercises are delivered as complete, working programs that demonstrate the concept. The student reads, runs, modifies, and experiments
- **D-08:** Each exercise has a README.md explaining the concept briefly, listing what to observe, and suggesting modifications to try. Code has inline comments explaining each instruction
- **D-09:** All READMEs, code comments, and documentation are in English

### Verification Mechanism
- **D-10:** `make check` runs the program, captures stdout, and compares byte-for-byte against an `expected_output` file using `diff -u`. Prints PASS on match, FAIL with visible diff on mismatch
- **D-11:** A root-level Makefile provides `make check-all` that recursively runs `make check` in every exercise directory — useful for validating the full suite after toolchain changes
- **D-12:** Comparison is exact (byte-for-byte) — no whitespace tolerance. Exercises teach precise output production

### Claude's Discretion
- Exact content and progression within each exercise
- How print_uint64 helper is implemented internally
- Makefile variable naming and internal structure
- README depth and structure (within the "concept + annotations" framework)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project specs
- `.planning/REQUIREMENTS.md` — Requirements TOOL-01 through ASM-07 define what this phase must deliver
- `.planning/ROADMAP.md` §Phase 1 — Success criteria (4 items) that must be TRUE after execution
- `CLAUDE.md` §Technology Stack — Full toolchain specification (NASM, GCC flags, GDB, GEF, Unity, etc.)
- `CLAUDE.md` §Recommended Stack > Assembler — Intel syntax rationale and NASM version

### External references
- NASM documentation: https://www.nasm.us/doc/
- Linux syscall table for x86-64 (sys_write=1, sys_exit=60)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None — project is brand new, no existing source code

### Established Patterns
- None yet — this phase establishes the foundational patterns for all subsequent phases

### Integration Points
- `lib/print_uint64.asm` will be created in this phase and reused by Phase 2 (stack/functions) exercises
- The Makefile pattern established here (per-exercise Makefile + root recursive Makefile) will be extended for C exercises in Phase 3

</code_context>

<specifics>
## Specific Ideas

- Exercises should feel like working examples the student can dissect and modify, not puzzles to solve
- The print_uint64 helper should be treated as a "black box" initially — explained later when the student has the knowledge to understand integer-to-string conversion
- Topic grouping (01-registers, 02-flow-control, 03-memory) mirrors the natural learning progression

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-toolchain-and-assembly-basics*
*Context gathered: 2026-04-06*
