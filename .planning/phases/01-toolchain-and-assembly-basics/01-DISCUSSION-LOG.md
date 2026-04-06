# Phase 1: Toolchain and Assembly Basics - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-06
**Phase:** 01-toolchain-and-assembly-basics
**Areas discussed:** Output Method, Directory Structure, Exercise Format, Verification Mechanism

---

## Output Method

| Option | Description | Selected |
|--------|-------------|----------|
| Syscalls Linux (write + exit) | Usar sys_write para stdout e sys_exit. Mais educativo, sem dependência de libc. | ✓ |
| Printf via libc | Linkar contra libc e usar printf/puts. Esconde mecânica de I/O. | |
| Exit codes apenas | Retornar resultado via exit code. Limitado a 0-255. | |

**User's choice:** Syscalls Linux (write + exit)
**Notes:** None

### Integer-to-string conversion

| Option | Description | Selected |
|--------|-------------|----------|
| Helper fornecido | Fornecer rotina print_uint64 pronta. Foco na aritmética, não na conversão. | ✓ |
| Estudante implementa | Exercício ensina a conversão. Mais completo, mais complexo. | |
| Verificar via exit code | Exercícios aritméticos retornam resultado como exit code. | |

**User's choice:** Helper fornecido
**Notes:** None

### String definition

| Option | Description | Selected |
|--------|-------------|----------|
| Seção .data com labels | Strings definidas em section .data com db. Padrão clássico NASM. | ✓ |
| Seção .rodata | Usar .rodata (read-only data). Mais correto semanticamente. | |
| Você decide | Deixar Claude escolher. | |

**User's choice:** Seção .data com labels
**Notes:** None

---

## Directory Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Um diretório por exercício | Cada exercício isolado com Makefile, README, expected output. Agrupados por tópico. | ✓ |
| Flat por tópico | Cada tópico é um diretório com vários .asm e um Makefile único. | |
| Completamente flat | Todos exercícios na raiz com prefixo numérico. | |

**User's choice:** Um diretório por exercício
**Notes:** None

### Shared helpers location

| Option | Description | Selected |
|--------|-------------|----------|
| lib/ na raiz do projeto | Um único diretório lib/ na raiz. Exercícios e C podem compartilhar helpers. | ✓ |
| lib/ dentro de cada módulo | Cada tópico tem seus próprios helpers. | |
| Você decide | Deixar Claude escolher. | |

**User's choice:** lib/ na raiz do projeto
**Notes:** None

### Source file naming

| Option | Description | Selected |
|--------|-------------|----------|
| main.asm | Sempre main.asm. Consistente, Makefile genérico funciona em todos. | ✓ |
| Nome descritivo | Nome do arquivo reflete o conteúdo. Makefile precisa de variável por exercício. | |

**User's choice:** main.asm
**Notes:** None

---

## Exercise Format

| Option | Description | Selected |
|--------|-------------|----------|
| Programa completo pronto | Exercício vem com código funcional. Estudante lê, roda, modifica. | ✓ |
| Template com TODOs | Estrutura fornecida, estudante preenche partes-chave. | |
| Arquivo vazio + instruções | Só README com instruções. Estudante escreve do zero. | |

**User's choice:** Programa completo pronto
**Notes:** None

### README role

| Option | Description | Selected |
|--------|-------------|----------|
| Conceito + anotações no código | README explica conceito teórico, lista o que observar, sugere modificações. | ✓ |
| README mínimo, código auto-explicativo | README só com 'make run' e 'make check'. | |
| Você decide | Deixar Claude escolher. | |

**User's choice:** Conceito + anotações no código
**Notes:** None

### Language

| Option | Description | Selected |
|--------|-------------|----------|
| Português | Consistente com estudo pessoal. READMEs e comentários em PT-BR. | |
| Inglês | Acompanha documentação técnica padrão e manuais Intel. Repo público. | ✓ |
| Misto | README em português, comentários inline em inglês. | |

**User's choice:** Inglês
**Notes:** None

---

## Verification Mechanism

| Option | Description | Selected |
|--------|-------------|----------|
| Diff stdout vs expected_output | Roda programa, captura stdout, compara via diff -u. PASS/FAIL com diff visível. | ✓ |
| Diff + exit code | Combina verificação de stdout E do exit code. | |
| Script de verificação custom | Script check.sh por exercício para verificações complexas. | |

**User's choice:** Diff stdout vs expected_output
**Notes:** None

### Root Makefile

| Option | Description | Selected |
|--------|-------------|----------|
| Sim, Makefile raiz recursivo | Makefile na raiz com 'make check-all' percorrendo todos os diretórios. | ✓ |
| Não, só Makefile por exercício | Cada exercício é independente. | |

**User's choice:** Sim, Makefile raiz recursivo
**Notes:** None

### Whitespace tolerance

| Option | Description | Selected |
|--------|-------------|----------|
| Comparação exata | expected_output é byte-a-byte. Sem tolerância a whitespace extra. | ✓ |
| Tolerância a whitespace | Ignorar diferenças de trailing whitespace e linhas vazias extras. | |
| Você decide | Deixar Claude escolher. | |

**User's choice:** Comparação exata
**Notes:** None

---

## Claude's Discretion

- Exact content and progression within each exercise
- How print_uint64 helper is implemented internally
- Makefile variable naming and internal structure
- README depth and structure

## Deferred Ideas

None — discussion stayed within phase scope
