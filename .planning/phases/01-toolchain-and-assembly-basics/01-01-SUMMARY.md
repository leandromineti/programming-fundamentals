---
phase: 01-toolchain-and-assembly-basics
plan: "01"
subsystem: toolchain-and-first-exercise
tags: [assembly, nasm, x86-64, toolchain, gdb, makefile]
dependency_graph:
  requires: []
  provides:
    - lib/print_uint64.asm (shared integer-to-stdout helper for all numeric exercises)
    - 01-registers/asm-01-mov/ (first exercise, reference pattern for all subsequent exercises)
    - Makefile (root check-all/clean-all entry point)
    - .gdbinit (Intel syntax for GDB)
    - .gitignore (build artifact exclusions)
  affects:
    - All subsequent plans depend on lib/print_uint64.asm for numeric output
    - All exercise plans follow the Makefile + expected_output pattern established here
tech_stack:
  added:
    - NASM 2.16.03 (Fedora 43 via dnf)
    - GCC 15.2.1 (Fedora 43 -- deviation from Ubuntu 14.2.0 target)
    - GNU Make 4.4.1
    - GDB 17.1 (Fedora)
  patterns:
    - per-exercise Makefile with build/run/check/clean targets
    - diff -u expected_output actual.txt for byte-for-byte verification
    - Linux syscalls sys_write(1) + sys_exit(60), no libc dependency
    - global _start entry point linked with ld directly
key_files:
  created:
    - lib/print_uint64.asm
    - Makefile
    - .gdbinit
    - .gitignore
    - 01-registers/asm-01-mov/main.asm
    - 01-registers/asm-01-mov/expected_output
    - 01-registers/asm-01-mov/Makefile
    - 01-registers/asm-01-mov/README.md
  modified: []
decisions:
  - WSL2 uses Fedora 43 (not Ubuntu 24.04) -- toolchain installed via dnf; NASM 2.16.03 and GCC 15.2.1 are fully functional equivalents
  - Build artifacts (.o, main, actual.txt) excluded via .gitignore to keep repo clean
  - asm-01-mov exercise uses only sys_write string messages -- no print_uint64 dependency needed for this exercise
metrics:
  duration_minutes: 4
  completed_date: "2026-04-06"
  tasks_completed: 2
  files_created: 8
  files_modified: 0
---

# Phase 01 Plan 01: Toolchain Setup and First Exercise (asm-01-mov) Summary

**One-liner:** NASM + GCC + Make + GDB toolchain installed via WSL2 (Fedora 43); lib/print_uint64.asm div-loop helper created; asm-01-mov exercise demonstrates mov across all register widths with diff-based verification passing.

## What Was Built

### Task 1: Toolchain verification + shared library + root Makefile + .gdbinit

Installed and verified the full toolchain in WSL2 (Fedora 43):
- NASM 2.16.03, GCC 15.2.1, GNU Make 4.4.1, GDB 17.1

Created `lib/print_uint64.asm`: a shared assembly routine (div-loop approach) that takes a 64-bit unsigned integer in `rdi` (System V ABI) and writes it to stdout as decimal ASCII followed by a newline using `sys_write`. Assembles cleanly with `nasm -f elf64 -g`.

Created root `Makefile` with `check-all` (tolerant counting: tallies PASS/FAIL across all exercises) and `clean-all` targets. `EXERCISES` variable starts with only `01-registers/asm-01-mov` -- subsequent plans extend this list.

Created `.gdbinit` with `set disassembly-flavor intel` so GDB always uses Intel syntax matching NASM source.

**Commits:** 8f5a960

### Task 2: asm-01-mov exercise

Created `01-registers/asm-01-mov/` with four files:

- `main.asm`: Demonstrates all four `mov` variants across register widths (rax/eax/ax/al), with heavy inline commentary explaining the zero-extension rule (32-bit writes clear upper 32 bits of rax; 16-bit and 8-bit writes do not). Uses sys_write + sys_exit syscalls, no libc.
- `expected_output`: Byte-for-byte exact stdout match.
- `Makefile`: Per-exercise build with build/run/check/clean targets; uses `diff -u expected_output actual.txt` for verification; no print_uint64 dependency (exercise only prints string labels).
- `README.md`: Concept explanation, build instructions, observation notes, modification suggestions, 5-command GDB starter kit.

`make check` prints PASS. `make check-all` from root prints "Results: 1 passed, 0 failed".

**Commits:** 3206405

### Deviation: .gitignore creation

Added `.gitignore` to exclude build artifacts (`*.o`, `main`, `actual.txt`) and the `.claude/` GSD tooling directory. Not in original plan but required to keep generated files out of the repo (Rule 2: missing critical functionality for correct operation).

**Commit:** d92014f

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing] Created .gitignore for build artifacts**
- **Found during:** Task 2 (after running make check, binary and .o files appeared as untracked)
- **Issue:** No .gitignore existed; build artifacts (main, *.o, actual.txt) would be staged accidentally
- **Fix:** Created `.gitignore` excluding build artifacts and `.claude/` GSD tooling directory
- **Files modified:** `.gitignore` (created)
- **Commit:** d92014f

**2. [Rule 1 - Environmental] WSL2 runs Fedora 43, not Ubuntu 24.04**
- **Found during:** Task 1 toolchain verification
- **Issue:** Plan and CLAUDE.md reference Ubuntu 24.04 and apt; the actual WSL2 instance runs Fedora 43 with dnf
- **Fix:** Installed toolchain via `sudo dnf install -y nasm gcc make gdb binutils`. Tools are functionally equivalent. GCC version is 15.2.1 (not 14.2.0) -- this does not affect assembly exercises.
- **Impact:** None on correctness. CLAUDE.md technology stack section refers to Ubuntu versions for documentation purposes; the actual installed versions are newer and fully compatible.
- **No commit needed:** This was a runtime discovery, not a code change.

## Verification Results

| Check | Result |
|-------|--------|
| nasm --version | NASM version 2.16.03 -- PASS |
| gcc --version | GCC 15.2.1 -- PASS (newer than expected) |
| make --version | GNU Make 4.4.1 -- PASS |
| gdb --version | GNU gdb 17.1 -- PASS (newer than expected) |
| nasm -f elf64 -g lib/print_uint64.asm | exit 0 -- PASS |
| make check (asm-01-mov) | PASS |
| make check-all | Results: 1 passed, 0 failed -- PASS |
| .gdbinit contains set disassembly-flavor intel | PASS |

## Self-Check: PASSED

All files verified to exist and commits verified to be present in git log.
