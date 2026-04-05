# Architecture Patterns

**Domain:** Self-study programming exercise repository (x86-64 assembly + C)
**Researched:** 2026-04-05
**Confidence:** MEDIUM — derived from real-world repositories (rustlings, exercism x86-64, dtg-lucifer/x86_64-asm-101, ALX low-level-programming) plus verified toolchain documentation.

---

## Recommended Architecture

A flat topic-module layout with a single root Makefile that delegates to per-exercise Makefiles. Exercises within each module are numbered. Solutions live in a parallel `solutions/` tree.

```
programming-fundamentals/
├── Makefile                  # Root: build-all, check-all, clean-all targets
├── README.md                 # Repo overview + how to run exercises
├── toolchain.md              # WSL setup: nasm, gcc, ld, gdb
│
├── 01-registers/             # Module 1
│   ├── README.md             # Module learning objectives + resources
│   ├── 01-hello-registers/   # Exercise 1-01
│   │   ├── exercise.asm      # Source stub with TODO comments
│   │   ├── expected.txt      # Expected stdout (used by make check)
│   │   ├── Makefile          # build / run / check / clean
│   │   └── README.md         # Problem statement + hints
│   ├── 02-arithmetic/
│   │   └── ...
│   └── 03-comparisons/
│       └── ...
│
├── 02-memory/                # Module 2
│   ├── README.md
│   ├── 01-data-section/
│   ├── 02-bss-section/
│   └── 03-addressing-modes/
│
├── 03-stack-and-calls/       # Module 3
│   ├── README.md
│   ├── 01-push-pop/
│   ├── 02-call-ret/
│   ├── 03-stack-frame/
│   └── 04-systemv-abi/
│
├── 04-c-fundamentals/        # Module 4
│   ├── README.md
│   ├── 01-pointers/
│   ├── 02-structs/
│   └── 03-malloc-free/
│
├── 05-c-meets-assembly/      # Module 5
│   ├── README.md
│   ├── 01-read-disassembly/
│   ├── 02-c-calls-asm/
│   └── 03-asm-calls-c/
│
└── solutions/                # Mirror tree of solved exercises
    ├── 01-registers/
    │   ├── 01-hello-registers/
    │   │   └── solution.asm
    │   └── ...
    └── ...
```

---

## Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| Root `Makefile` | Recursive build/check/clean over all modules | Each module's Makefile |
| Module directory (`NN-topic/`) | Groups related exercises; contains module README | Root Makefile, exercise Makefiles |
| Exercise directory (`NN-name/`) | Single self-contained problem: source + expected output + Makefile + README | Module directory, `solutions/` mirror |
| `exercise.asm` / `exercise.c` | Stub file the learner edits | Exercise Makefile (compiled), `expected.txt` (verified) |
| `expected.txt` | Ground truth for stdout comparison | Exercise Makefile `check` target |
| `solutions/` | Reference implementations; never imported by exercises | Learner reference only |

---

## Data Flow

```
Learner edits exercise.asm
         |
         v
   make build
   (nasm -f elf64 exercise.asm -o exercise.o)
   (ld exercise.o -o exercise  OR  gcc exercise.o -o exercise)
         |
         v
   ./exercise > actual.txt
         |
         v
   diff actual.txt expected.txt
         |
    PASS / FAIL stdout
```

For C exercises that call assembly (Module 5):

```
   gcc -c c_caller.c -o c_caller.o
   nasm -f elf64 asm_routine.asm -o asm_routine.o
   gcc c_caller.o asm_routine.o -o exercise
```

---

## Exercise File Conventions

### Assembly exercise (Modules 1–3)

```
exercise.asm   — learner edits this; marked with ; TODO: implement
Makefile       — build / run / check / clean targets
expected.txt   — exact expected stdout, newline-terminated
README.md      — problem statement, hints, references
```

### C exercise (Module 4)

```
exercise.c     — learner edits this; marked with /* TODO: implement */
Makefile       — gcc build + check
expected.txt   — exact expected stdout
README.md      — problem statement, hints
```

### Mixed C+Assembly exercise (Module 5)

```
main.c         — C harness (given, do not edit)
routine.asm    — learner implements the assembly routine
Makefile       — compiles both, links, checks
expected.txt   — exact expected stdout
README.md      — what the compiler generated vs what you write by hand
```

---

## Per-Exercise Makefile Pattern

```makefile
ASM    = nasm
CC     = gcc
LD     = ld
ASMFLAGS = -f elf64 -g
CFLAGS   = -Wall -g -no-pie

SRC    = exercise.asm
OBJ    = $(SRC:.asm=.o)
BIN    = exercise

.PHONY: build run check clean

build: $(BIN)

$(BIN): $(OBJ)
	$(LD) -o $@ $^

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

run: build
	./$(BIN)

check: build
	./$(BIN) > actual.txt
	diff -u expected.txt actual.txt && echo "PASS" || (echo "FAIL" && exit 1)
	@rm -f actual.txt

clean:
	rm -f $(OBJ) $(BIN) actual.txt
```

Exercises that need libc (printf, scanf) use `gcc` for linking instead of `ld`.

---

## Root Makefile Pattern

```makefile
MODULES := 01-registers 02-memory 03-stack-and-calls 04-c-fundamentals 05-c-meets-assembly

.PHONY: all check clean $(MODULES)

all:
	@for m in $(MODULES); do \
	  $(MAKE) -C $$m all 2>/dev/null || true; \
	done

check:
	@pass=0; fail=0; \
	for m in $(MODULES); do \
	  for ex in $$m/*/; do \
	    if $(MAKE) -C $$ex check -s 2>/dev/null; then \
	      echo "PASS  $$ex"; pass=$$((pass+1)); \
	    else \
	      echo "FAIL  $$ex"; fail=$$((fail+1)); \
	    fi; \
	  done; \
	done; \
	echo ""; echo "Results: $$pass passed, $$fail failed"

clean:
	@for m in $(MODULES); do \
	  $(MAKE) -C $$m clean 2>/dev/null || true; \
	done
```

Module-level Makefiles delegate further to exercise Makefiles with the same pattern.

---

## Build Order (Topic Dependencies)

The module numbers encode a strict dependency chain. No module can be fully understood without completing the one before it.

```
01-registers
    Required by: everything — registers are the primitive of x86-64
         |
         v
02-memory
    Covers: sections (.data, .bss), addressing modes, load/store
    Required by: 03 (stack is memory), 04 (C memory model), 05
         |
         v
03-stack-and-calls
    Covers: push/pop, call/ret, stack frames, System V AMD64 ABI
    Required by: 05 (mixed C+asm — calling convention must be known)
         |
         v
04-c-fundamentals
    Covers: pointers, structs, malloc/free — in C, no assembly
    Required by: 05 (you need to read C to understand disassembly)
         |
         v
05-c-meets-assembly
    Covers: reading disassembly, C calling asm, asm calling C
    Terminal module — integrates all prior knowledge
```

**Why this order:**
- Module 01 before 02: You must understand what registers hold before you study how memory feeds them.
- Module 03 before 05: The System V ABI (how arguments pass in rdi, rsi, rdx...) is essential before writing assembly called from C.
- Module 04 before 05: Reading disassembly of pointer arithmetic requires understanding what the C source was doing first.
- Modules 04 and 03 can be developed in parallel as content, but 03 must be taught before 05.

---

## Patterns to Follow

### Pattern 1: Expected-Output Verification via diff

**What:** Each exercise has an `expected.txt` file checked in to the repository. `make check` runs the binary and pipes stdout to `diff`.

**When:** All exercises. This is the primary correctness signal.

**Why:** No testing framework dependency. Portable to any Unix shell. Output is unambiguous for exercises that print a value, a computed result, or a register dump.

**Limitation:** Not suitable for interactive exercises (requiring stdin) without input fixtures — but this repo's exercises are output-only by design.

### Pattern 2: Numbered Prefix for Ordering, Kebab Name for Readability

**What:** Modules use `NN-topic-name/` and exercises within use `NN-short-name/`.

**When:** All directories.

**Why:** Shell glob `*/` iteration respects alphabetical order, which coincides with numeric order when zero-padded. This means `make check` and `ls` both traverse exercises in pedagogical sequence without configuration.

**Evidence:** Used by dtg-lucifer/x86_64-asm-101 (`01_hello_world`, `02_extern`...) and ALX low-level programming (`0x00-hello_world`, `0x05-pointers_arrays_strings`...).

### Pattern 3: Solutions in a Parallel Tree, Never Symlinked

**What:** `solutions/` mirrors the exercise tree exactly but contains complete implementations.

**When:** All exercises.

**Why:** Learner can diff their file against the solution for any exercise without the solution being visible during normal work. The `solutions/` directory is never a build target.

**Evidence:** Rustlings keeps `exercises/` and `solutions/` as sibling directories at repo root.

### Pattern 4: Module README with Learning Objectives

**What:** Each module directory has a `README.md` listing what the learner should understand before starting, what each exercise covers, and links to authoritative references (Intel manual sections, CS:APP chapters).

**When:** Every module.

**Why:** Exercises without context are puzzles. The module README converts puzzles into directed learning.

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Single Flat Directory for All Exercises

**What:** All exercises in `exercises/` with no sub-grouping.

**Why bad:** At 15-20 exercises, navigation becomes opaque. There is no visual signal of which exercises form a conceptual group. Build-order dependencies become implicit.

**Instead:** Group by module with numeric prefix.

### Anti-Pattern 2: Build Artifacts in Source Directories Without .gitignore

**What:** Object files and binaries accumulate alongside source.

**Why bad:** Git status becomes noisy; learners accidentally commit binaries.

**Instead:** A root `.gitignore` covering `*.o`, `exercise` (binary), `actual.txt` keeps source directories clean. Each per-exercise `make clean` removes artifacts.

### Anti-Pattern 3: Testing Framework Dependency for Simple Output Checks

**What:** Unity, Check, or Google Test linked into assembly/C exercises.

**Why bad:** Adds build complexity. For this repo, exercises produce deterministic stdout — a test framework is overkill and adds friction for a solo learner.

**Exception:** Module 5 mixed exercises that test return values (not stdout) may benefit from a minimal C harness that calls the assembly function and prints PASS/FAIL. This is still simpler than a full test framework.

**Instead:** `diff expected.txt actual.txt` for output exercises; a purpose-written `harness.c` for function-level tests in Module 5.

### Anti-Pattern 4: Global Build-All as First Instruction

**What:** README says "run `make` to build everything."

**Why bad:** A learner who has not completed module 1 will get build failures on all later modules because stub files do not compile. This creates false failure signals.

**Instead:** Root `Makefile` has a `check` target that tolerates per-exercise failures (counts pass/fail) and a module-level `build` target that only builds that module. Instructions say "work through modules in order."

---

## Scalability Considerations

| Concern | Current scope (20 exercises) | Future scope (50+ exercises) |
|---------|------------------------------|------------------------------|
| Build time | Instantaneous with per-exercise Makefiles | Still fast — assembly files are small; recursive make adds latency at scale |
| Navigation | Module numbering sufficient | May add a `scripts/status.sh` that prints PASS/FAIL per exercise like rustlings watch |
| Adding new topics | New module directory, update root Makefile MODULES variable | Same pattern scales; consider a `config.toml` manifest if topics proliferate |
| WSL path issues | Not a concern — all paths relative | Not a concern |

---

## Sources

- rustlings repository structure: https://github.com/rust-lang/rustlings/ (MEDIUM confidence — inferred from public docs, not direct code read)
- rustlings info.toml format: https://rustlings.rust-lang.org/community-exercises/ and fork mirrors (HIGH confidence — consistent across multiple forks)
- exercism x86-64-assembly track structure: https://github.com/exercism/x86-64-assembly (MEDIUM confidence — directory listing only, file internals inferred)
- exercism x86-64 toolchain recommendation (NASM + System V ABI): https://exercism.org/docs/tracks/x86-64-assembly/installation (HIGH confidence — official docs)
- numerically-prefixed folder pattern: https://github.com/dtg-lucifer/x86_64-asm-101 (HIGH confidence — direct directory listing)
- hexadecimal prefix pattern: https://github.com/khalid1sey/alx-low_level_programming (HIGH confidence — direct listing)
- per-exercise Makefile pattern (nasm -f elf64 → ld): https://gist.github.com/yellowbyte/d91da3c3b0bc3ee6d1d1ac5327b1b4b2 (HIGH confidence — concrete Makefile example)
- recursive Makefile for subdirectory builds: https://www.gnu.org/software/make/manual/html_node/Recursion.html (HIGH confidence — GNU Make official docs)
- diff-based expected output verification: https://www.cs.toronto.edu/~penny/teaching/csc444-05f/maketutorial.html (MEDIUM confidence — academic course material)
- CS:APP Architecture Lab structure: https://csapp.cs.cmu.edu/3e/labs.html (MEDIUM confidence — public lab description page)
