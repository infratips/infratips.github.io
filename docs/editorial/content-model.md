# Modelo de conteudo

## Contrato minimo

Todo arquivo em `_posts/` precisa informar:

```yaml
---
title: "Titulo objetivo"
summary: "Resumo curto usado na pagina e em metadados."
type: article
category: cloud-devops
tags:
  - cloud
status: published
---
```

O Jekyll deriva com seguranca:

- `layout`: default de posts em `_config.yml`;
- `author`: autor padrao em `_config.yml`, com override opcional;
- `date`: prefixo `YYYY-MM-DD` do nome do arquivo;
- `slug` e URL: restante do nome do arquivo e permalink global;
- `footer`, `maximize`, `toc_level`: defaults de apresentacao.

Nao use `published`. `status` e o unico campo de ciclo editorial. Na P1, `_posts/` aceita somente `published`; agendamento e rascunhos exigem uma decisao posterior.

## Campos comuns opcionais

| Campo | Uso |
| --- | --- |
| `author` | Sobrescreve o autor padrao. |
| `updated` | Data ISO 8601 da ultima atualizacao significativa. |
| `level` | Conforme politica do tipo. |
| `slug` | Override excepcional; normalmente derivado do arquivo. |
| `image` | Imagem editorial local ou remota. |
| `image_alt` | Obrigatorio quando `image` e definido. |

Tags usam IDs em minusculas, sem espacos, como `linux`, `aws` ou `open-source`.

## Politica de nivel

- `tutorial` e `tip`: obrigatorio;
- `article` e `experience`: opcional;
- `news` e `event`: proibido por nao representar progressao tecnica.

Os valores validos estao em `_data/levels.yml`.

## Campos condicionais

### Noticia comentada

`news` exige `source_name`, `source_url` e `source_date`. O corpo deve separar resumo factual, comentario InfraTips e impacto pratico. A fonte original permanece visivel; conteudo externo nao deve ser reproduzido integralmente.

### Evento

`event` exige `starts_at`, `timezone` e `mode`. Use data ISO 8601 (`2026-09-10`) quando a fonte divulgar somente o dia, ou data/hora ISO 8601 com timezone (`2026-09-10T19:00:00-03:00`) quando houver horario confirmado. `mode` aceita `online`, `in-person` ou `hybrid`.

Campos opcionais: `ends_at`, `location`, `registration_url`, `recording_url`, `slides_url` e `repository_url`.

### InfraTip

Uma `tip` tem normalmente 100 a 500 palavras e organiza contexto, comando ou recomendacao, explicacao, cuidado e referencia opcional. Imagem, thumbnail, indice e conclusao formal nao sao obrigatorios.

### Experiencia de campo

Uma `experience` deve tornar reconheciveis contexto, problema, diagnostico, solucao, resultado e licoes. Esses blocos permanecem no Markdown, sem campos artificiais de front matter.

## Apresentacao por tipo

Tutorial e experiencia de campo usam o mesmo layout editorial, mas recebem um guia visual leve antes do corpo. O tutorial destaca o uso sequencial do procedimento; a experiencia destaca contexto, diagnostico, solucao e resultado. O guia nao substitui os blocos reais do Markdown nem cria um novo tipo de conteudo.

## Imagens

Imagens sao opcionais. Quando usadas no front matter, informe `image_alt`; quando usadas no corpo Markdown, escreva alt significativo. Caminhos locais precisam existir. Thumbnails nao sao obrigatorias para nenhum tipo na P1.
