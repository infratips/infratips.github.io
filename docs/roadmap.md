# Roadmap e continuidade

## Fases

- P0 — Fundacao tecnica e UX: concluida e publicada.
- P1 — Modelo editorial: concluída e publicada no merge `ef851712`.
- P2 — Home e descoberta: concluida e publicada no merge `87433a0`.
- Acervo editorial inicial: implementado e em validacao na branch `feat/initial-content-library`.
- P3 — Experiencia educacional: nao iniciada.
- P4 — Preparacao para Cortex: nao iniciada.

## Handoff

**LAST COMPLETED:** P2 publicada no merge `87433a0`, com CI, GitHub Pages e producao mobile validados.

**CURRENT STATE:** o acervo inicial usa o contrato editorial em `_posts/`: tres InfraTips, um tutorial, um artigo, uma experiencia de campo e um evento curado. O validador aceita eventos de dia inteiro sem inventar horario; build, HTML Proofer, anti-drift e Playwright nos quatro breakpoints estao verdes localmente.

**PARTIALLY COMPLETED:** revisao humana, CI remoto e publicacao do acervo editorial inicial.

**BLOCKED:** nenhum bloqueio conhecido.

**PENDING HUMAN DECISIONS:** aprovar ou solicitar ajustes no acervo editorial antes de iniciar P3.

**NEXT CRITICAL ACTION:** abrir a PR do acervo inicial, validar CI e artefatos e aguardar revisao, sem iniciar P3.

**NEXT 5:** abrir PR do acervo; confirmar CI; revisar artefatos; fazer merge somente com autorizacao humana; iniciar P3 somente apos producao validada.
