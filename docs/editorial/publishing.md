# Publicacao editorial

## Criar conteudo

1. Crie uma branch a partir de `master` atualizado.
2. Adicione `_posts/YYYY-MM-DD-slug.md`.
3. Preencha o contrato minimo e os campos condicionais do tipo.
4. Escreva o corpo em Markdown, sem editar layouts ou indices.
5. Execute as validacoes locais.
6. Abra Pull Request, revise o artefato e aguarde o CI.
7. Obtenha aprovacao humana antes do merge.

```bash
bundle exec ruby scripts/validate_content.rb --self-test
bundle exec ruby scripts/validate_content.rb
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter --trace
bundle exec htmlproofer ./_site --disable-external
npm test
```

O validador rejeita enums desconhecidos, metadados condicionais incorretos, datas invalidas, tags malformadas, URLs/slugs duplicados, imagens ausentes ou sem alt, links internos quebrados e layouts inexistentes. O HTML Proofer valida os links internos depois da renderizacao.

## Alterar o contrato

Tipos, categorias, levels ou status novos exigem mudanca em `_data`, validacao, documentacao e teste no mesmo Pull Request. Labels nunca devem ser hardcoded em novos templates.

## Rollback

Reverta o commit ou merge responsavel e envie a reversao para `master`. Como Git e a fonte de verdade, o GitHub Pages recompila o estado anterior sem migracao de dados.

## Definition of Done editorial

Alem dos checks tecnicos, registre Architecture Impact e Documentation Impact no Pull Request. Rode `/docs-vivas check`; ao fechar uma fase do roadmap, atualize `docs/roadmap.md` e rode `/docs-vivas handoff`.
