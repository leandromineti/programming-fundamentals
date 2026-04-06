# Programming Fundamentals

A personal study repository exploring the layers of software abstraction — from hardware registers up to high-level languages. Each topic contains executable exercises that build foundations for the topics that follow.

## Goal

Understand how software really works — from the register to the framework — being able to trace any abstraction back to its concrete implementation.

## Structure

```
01-registers/          # x86-64 registers, mov instruction, sub-register behavior
  asm-01-mov/          # Register sizes and the zero-extension rule
lib/                   # Shared assembly utilities (e.g., print_uint64)
Makefile               # Root build: check-all, clean-all
```

Each exercise directory has its own `Makefile` and `README.md` with build instructions, concepts, and GDB walkthroughs.

## Requirements

- **Platform**: x86-64 Linux (WSL2 works)
- **Toolchain**: NASM, GCC, GNU Make, GDB
- **Optional**: GEF (GDB enhancement for register visualization)

## Quick Start

```bash
# Run all exercises and check outputs
make check-all

# Run a single exercise
cd 01-registers/asm-01-mov
make check

# Clean build artifacts
make clean-all
```

## Exercises

| # | Directory | Topic |
|---|-----------|-------|
| 1 | `01-registers/asm-01-mov` | Register sizes (64/32/16/8-bit), `mov` variants, zero-extension rule |

## License

MIT
