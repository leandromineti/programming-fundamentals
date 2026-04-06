# Requirements: Programming Fundamentals

**Defined:** 2026-04-06
**Core Value:** Entender como software realmente funciona — do registrador ao framework — sendo capaz de rastrear qualquer abstração até sua implementação concreta.

## v1 Requirements

Assembly como fundação mínima para habilitar uma conversa informada sobre C. C é o foco principal.

### Toolchain

- [ ] **TOOL-01**: Ambiente WSL2 configurado com NASM, GCC, Make e GDB
- [ ] **TOOL-02**: Sistema de build com Makefile por módulo (compilar e rodar com um comando)
- [ ] **TOOL-03**: Verificação de exercícios via diff contra saída esperada (sem framework de testes)

### Assembly — Registradores e Operações Básicas

- [ ] **ASM-01**: Exercício com mov entre registradores e imediatos (entender tamanhos: rax, eax, ax, al)
- [ ] **ASM-02**: Exercício com add, sub, imul, idiv — operações aritméticas com registradores
- [ ] **ASM-03**: Exercício com cmp e jumps condicionais (je, jne, jl, jg) — controle de fluxo
- [ ] **ASM-04**: Exercício com loop simples usando contador em registrador

### Assembly — Memória e Endereçamento

- [ ] **ASM-05**: Exercício acessando dados em .data e .bss (variáveis globais)
- [ ] **ASM-06**: Exercício com modos de endereçamento: direto, indireto [reg], base+offset [reg+N]
- [ ] **ASM-07**: Exercício iterando sobre array em memória usando endereçamento indexado

### Assembly — Stack e Funções

- [ ] **ASM-08**: Exercício com push/pop — manipulação direta da stack
- [ ] **ASM-09**: Exercício definindo e chamando função própria com call/ret e stack frame
- [ ] **ASM-10**: Exercício com passagem de parâmetros seguindo System V ABI (rdi, rsi, rdx)
- [ ] **ASM-11**: Exercício demonstrando callee-saved vs caller-saved registers na prática

### C — Ponteiros e Arrays

- [ ] **C-01**: Exercício com ponteiros básicos (declaração, desreferência, endereço-de)
- [ ] **C-02**: Exercício com aritmética de ponteiros e relação com arrays
- [ ] **C-03**: Exercício com strings em C (char*, null-terminator, funções de string)
- [ ] **C-04**: Exercício com ponteiros para ponteiros e arrays multidimensionais

### C — Structs e Memória

- [ ] **C-05**: Exercício com structs (definição, acesso a campos, ponteiros para struct)
- [ ] **C-06**: Exercício demonstrando layout de struct em memória (sizeof, offsetof, padding)
- [ ] **C-07**: Exercício com malloc/free — alocação dinâmica e ciclo de vida da memória
- [ ] **C-08**: Exercício construindo estrutura de dados simples (linked list) com alocação dinâmica

### C — Funções e Stack

- [ ] **C-09**: Exercício com passagem por valor vs passagem por ponteiro
- [ ] **C-10**: Exercício com função recursiva e visualização da stack (GDB)
- [ ] **C-11**: Exercício com variáveis locais, escopo e lifetime

### C-Assembly Bridge

- [ ] **BRG-01**: Exercício lendo disassembly de programa C simples (gcc -S, objdump -d)
- [ ] **BRG-02**: Exercício comparando código C com assembly gerado — identificar variáveis, loops, condicionais
- [ ] **BRG-03**: Exercício chamando função assembly a partir de C (e vice-versa)

## v2 Requirements

Reservado para milestones futuros.

### Sistema Operacional

- **SO-01**: Syscalls (write, read, exit) direto do assembly
- **SO-02**: Processos e fork
- **SO-03**: Sinais e signal handlers

### Assembly Avançado

- **ADV-01**: Operações com strings (rep movsb, scasb)
- **ADV-02**: Operações bitwise avançadas (shifts, masks, bit fields)
- **ADV-03**: SIMD básico (SSE/AVX)

### Otimizações

- **OPT-01**: Comparar -O0 vs -O2 — o que o compilador faz
- **OPT-02**: Loop unrolling e strength reduction no disassembly

## Out of Scope

| Feature | Reason |
|---------|--------|
| Linguagens de alto nível (Python, Go, Rust) | Reservado para milestones futuros |
| Conceitos de SO (syscalls, processos) | Reservado para v2 |
| Material didático para terceiros | Foco é estudo pessoal |
| Exercícios teóricos sem código | Tudo deve compilar e rodar |
| ABI como tópico isolado | Embutido nos exercícios de stack e funções |
| Otimizações do compilador como módulo | Reservado para v2, pode ser mencionado pontualmente |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| TOOL-01 | Phase 1 | Pending |
| TOOL-02 | Phase 1 | Pending |
| TOOL-03 | Phase 1 | Pending |
| ASM-01 | Phase 1 | Pending |
| ASM-02 | Phase 1 | Pending |
| ASM-03 | Phase 1 | Pending |
| ASM-04 | Phase 1 | Pending |
| ASM-05 | Phase 1 | Pending |
| ASM-06 | Phase 1 | Pending |
| ASM-07 | Phase 1 | Pending |
| ASM-08 | Phase 2 | Pending |
| ASM-09 | Phase 2 | Pending |
| ASM-10 | Phase 2 | Pending |
| ASM-11 | Phase 2 | Pending |
| C-01 | Phase 3 | Pending |
| C-02 | Phase 3 | Pending |
| C-03 | Phase 3 | Pending |
| C-04 | Phase 3 | Pending |
| C-05 | Phase 3 | Pending |
| C-06 | Phase 3 | Pending |
| C-07 | Phase 3 | Pending |
| C-08 | Phase 3 | Pending |
| C-09 | Phase 3 | Pending |
| C-10 | Phase 3 | Pending |
| C-11 | Phase 3 | Pending |
| BRG-01 | Phase 4 | Pending |
| BRG-02 | Phase 4 | Pending |
| BRG-03 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 28 total
- Mapped to phases: 28
- Unmapped: 0

---
*Requirements defined: 2026-04-06*
*Last updated: 2026-04-05 after roadmap creation — all 28 requirements mapped*
