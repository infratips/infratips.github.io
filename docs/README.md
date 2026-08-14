# Documentacao viva do InfraTips

Este diretorio e a fonte canonica para arquitetura, contrato editorial, publicacao e continuidade do InfraTips. `_data/` continua sendo a fonte executavel dos enums e labels; estes documentos explicam seu uso sem duplicar listas como configuracao.

## Padrao documental

- Documente somente comportamento existente ou identifique claramente uma decisao futura.
- Atualize o owner canonico da area no mesmo Pull Request que muda seu comportamento.
- Nao copie regras de produto para a skill global `/docs-vivas` nem para o adapter.
- Mantenha o adapter fino: caminhos, owners, papel do repositorio e comando anti-drift.
- Trate `_data/types.yml`, `_data/categories.yml`, `_data/levels.yml` e `_data/statuses.yml` como enums executaveis.
- Registre continuidade em `docs/roadmap.md` ao concluir cada fase.

## Owners canonicos

| Area | Owner |
| --- | --- |
| Arquitetura atual | `docs/architecture/overview.md` |
| Contrato de conteudo | `docs/editorial/content-model.md` |
| Taxonomia | `docs/editorial/taxonomy.md` |
| Publicacao e operacao editorial | `docs/editorial/publishing.md` |
| Descoberta, arquivos, relacionados e RSS | `docs/editorial/discovery.md` |
| Trilhas, carreira e uso educacional leve | `docs/editorial/learning-paths.md` |
| Comportamento responsivo do cabecalho | `docs/ui-ux/header-responsiveness.md` |
| Continuidade e roadmap | `docs/roadmap.md` |

## Definition of Done

Uma mudanca tecnica ou editorial relevante termina com:

1. validacao de conteudo e autoteste do detector;
2. build Jekyll e verificacao do HTML gerado;
3. smoke test renderizado quando houver impacto na interface;
4. classificacao de `ARCHITECTURE IMPACT`;
5. classificacao de `DOCUMENTATION IMPACT`;
6. atualizacao dos owners afetados;
7. execucao do comando anti-drift do adapter;
8. `/docs-vivas check` e, no fechamento de fase, `/docs-vivas handoff`.

`ANTI-DRIFT: PASS` confirma consistencia deterministica, mas nao substitui revisao semantica humana.
