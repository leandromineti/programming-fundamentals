# Roadmap: Programming Fundamentals

## Overview

Este roadmap leva o projeto do zero ao ponto em que o estudante consegue ler qualquer disassembly de C e rastrear cada decisão do compilador até o hardware. A sequência é não-negociável: registradores e memória constroem o vocabulário que torna a stack compreensível; a stack e as calling conventions constroem o contrato que torna o C legível; o C com fundamentos sólidos torna os exercícios de bridge reveladores em vez de enigmáticos.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Toolchain and Assembly Basics** - Ambiente configurado; exercícios de registradores, aritmética, controle de fluxo e memória funcionando
- [ ] **Phase 2: Assembly Stack and Functions** - Stack mecânica, calling conventions e funções ABI-compliant em assembly
- [ ] **Phase 3: C Fundamentals** - Ponteiros, structs, alocação dinâmica e funções em C, confirmados pelo modelo assembly
- [ ] **Phase 4: C-Assembly Bridge** - Exercícios de integração: ler disassembly de C, chamar assembly a partir de C e vice-versa

## Phase Details

### Phase 1: Toolchain and Assembly Basics
**Goal**: O estudante pode escrever, compilar, rodar e verificar exercícios em assembly x86-64 cobrindo registradores, aritmética, controle de fluxo e modos de endereçamento de memória
**Depends on**: Nothing (first phase)
**Requirements**: TOOL-01, TOOL-02, TOOL-03, ASM-01, ASM-02, ASM-03, ASM-04, ASM-05, ASM-06, ASM-07
**Success Criteria** (what must be TRUE):
  1. Um único comando (`make check`) compila e verifica qualquer exercício, produzindo PASS ou FAIL com diff visível
  2. O estudante pode escrever um programa em NASM que usa mov, add, sub, imul e idiv em registradores de larguras diferentes (rax/eax/ax/al) e produz saída verificável
  3. O estudante pode implementar branching (cmp + jcc) e loops com contador em registrador, produzindo saída que valida o fluxo correto
  4. O estudante pode acessar variáveis em .data e .bss e iterar sobre um array em memória usando endereçamento indexado [reg + N*const]
**Plans**: TBD

### Phase 2: Assembly Stack and Functions
**Goal**: O estudante pode escrever funções assembly ABI-compliant — com stack frame correto, preservação de registradores callee-saved e passagem de parâmetros via System V AMD64 ABI
**Depends on**: Phase 1
**Requirements**: ASM-08, ASM-09, ASM-10, ASM-11
**Success Criteria** (what must be TRUE):
  1. O estudante pode manipular a stack com push/pop e explicar o que rsp aponta a cada instrução (verificável via GDB)
  2. O estudante pode definir e chamar uma função própria com prologue/epilogue correto (push rbp / mov rbp,rsp / pop rbp / ret) e verificar o stack frame no GDB
  3. O estudante pode passar argumentos via rdi, rsi, rdx seguindo System V ABI e recuperar o retorno em rax, com saída verificável por diff
  4. O estudante pode demonstrar a diferença entre callee-saved (rbx, r12-r15) e caller-saved (rax, rcx, rdx, rdi, rsi) preservando os primeiros e não os segundos em funções aninhadas
**Plans**: TBD

### Phase 3: C Fundamentals
**Goal**: O estudante pode escrever programas C que manipulam ponteiros, structs e memória dinâmica, entendendo cada construção como uma notação de alto nível para operações assembly já conhecidas
**Depends on**: Phase 2
**Requirements**: C-01, C-02, C-03, C-04, C-05, C-06, C-07, C-08, C-09, C-10, C-11
**Success Criteria** (what must be TRUE):
  1. O estudante pode declarar, desreferenciar e operar com ponteiros (incluindo ponteiros para ponteiros e aritmética de ponteiros), relacionando cada operação ao modo de endereçamento assembly equivalente
  2. O estudante pode inspecionar o layout de uma struct em memória com sizeof e offsetof, explicar padding rules e verificar com GDB que os bytes batem com o esperado
  3. O estudante pode alocar e liberar memória com malloc/free, construir uma linked list e detectar leaks com ASan/Valgrind em todos os exercícios de memória dinâmica
  4. O estudante pode demonstrar passagem por valor vs. por ponteiro, escrever uma função recursiva e inspecionar os stack frames empilhados no GDB
**Plans**: TBD

### Phase 4: C-Assembly Bridge
**Goal**: O estudante pode ler disassembly de qualquer programa C simples, anotar variáveis, loops e condicionais, e escrever funções assembly chamáveis a partir de C — validando domínio completo da ABI ponta a ponta
**Depends on**: Phase 3
**Requirements**: BRG-01, BRG-02, BRG-03
**Success Criteria** (what must be TRUE):
  1. O estudante pode gerar e anotar o assembly de um programa C com gcc -S e objdump -d -S -M intel, identificando onde estão as variáveis locais, o loop e o condicional
  2. O estudante pode comparar o disassembly de -O0 com -O1/-O2 para o mesmo programa C e nomear pelo menos uma transformação que o compilador aplicou (ex: eliminação de frame pointer, invariant hoisting)
  3. O estudante pode escrever uma função em assembly puro, chamá-la a partir de C com argumentos e receber o retorno correto — e vice-versa — com saída verificável por diff
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Toolchain and Assembly Basics | 0/? | Not started | - |
| 2. Assembly Stack and Functions | 0/? | Not started | - |
| 3. C Fundamentals | 0/? | Not started | - |
| 4. C-Assembly Bridge | 0/? | Not started | - |
