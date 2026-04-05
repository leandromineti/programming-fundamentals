# Programming Fundamentals

## What This Is

Um repositório de estudo pessoal que explora as diferentes camadas de abstração do software, começando pelo hardware e subindo até linguagens de alto nível. Cada tópico contém exercícios executáveis que constroem fundamentos para os tópicos seguintes.

## Core Value

Entender como software realmente funciona — do registrador ao framework — sendo capaz de rastrear qualquer abstração até sua implementação concreta.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Exercícios em assembly x86-64 cobrindo registradores, memória e instruções básicas
- [ ] Exercícios em assembly sobre stack, calling conventions e stack frames
- [ ] Exercícios em C cobrindo ponteiros, structs e gerenciamento manual de memória
- [ ] Exercícios que conectam C ao assembly — ler disassembly, entender o que o compilador gera
- [ ] Cada exercício é executável (compilar, rodar, verificar resultado)
- [ ] Tópicos organizados em sequência progressiva (cada um depende do anterior)

### Out of Scope

- Linguagens de alto nível (Python, Go, Rust) — reservado para milestones futuros
- Conceitos de SO (syscalls, processos) — reservado para milestones futuros
- Material didático para terceiros — foco é estudo pessoal
- Exercícios teóricos sem código executável — tudo deve rodar

## Context

- Ambiente Windows 11 com acesso a WSL para toolchain nativo (gcc, nasm/gas)
- Arquitetura-alvo: x86-64 (nativa da máquina)
- Leandro é líder de dados e IA com experiência em linguagens de alto nível — o objetivo é preencher lacunas de conhecimento nas camadas mais baixas
- Repositório público no GitHub (leandromineti/programming-fundamentals)

## Constraints

- **Arquitetura**: x86-64 apenas — sem emuladores, exercícios rodam nativamente
- **Toolchain**: Ferramentas open-source (gcc, nasm ou gas) via WSL
- **Formato**: Todo exercício deve compilar e executar com instruções claras

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| x86-64 como arquitetura-alvo | Roda nativamente na máquina, sem setup de emulador | — Pending |
| Assembly antes de C | Entender o que está por baixo antes de usar a abstração | — Pending |
| Exercícios executáveis, não teoria | Aprendizado hands-on, verificável | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-05 after initialization*
