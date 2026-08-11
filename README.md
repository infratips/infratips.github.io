# InfraTips

O InfraTips e uma plataforma estatica de conteudo tecnico, experiencias praticas e orientacao para quem trabalha ou esta comecando em tecnologia. A identidade visual Matrix/terminal e parte do produto.

## Stack

- Jekyll e Liquid para geracao estatica;
- Markdown para conteudo;
- SCSS e JavaScript puro para interface;
- GitHub Pages para hospedagem;
- Git como fonte de verdade e mecanismo de rollback.

## Requisitos

- Ruby 3.2.3;
- Bundler 2.4 ou compativel;
- Node.js 20 ou superior apenas para os testes Playwright.

## Configuracao local

```bash
bundle install
npm ci
npx playwright install chromium
```

## Executar

```bash
bundle exec jekyll serve
```

O site fica disponivel em `http://127.0.0.1:4000`. Para incluir rascunhos, use `bundle exec jekyll serve --drafts`.

## Build e testes

```bash
bundle exec jekyll build --trace
bundle exec ruby scripts/validate_content.rb
bundle exec htmlproofer ./_site --disable-external
npm test
```

O Playwright gera um build de producao, inicia um servidor temporario em `http://127.0.0.1:4000`, executa os testes e encerra o servidor. Se essa porta ja estiver servindo o projeto, o servidor existente e reutilizado.

## Estrutura

```text
_config.yml       Configuracao global, dominio e redes sociais
_data/            Tipos, categorias, levels, status e labels controlados
_includes/        Componentes Liquid compartilhados
_layouts/         Layouts base e de conteudo
_posts/           Conteudo Markdown publicado
pages/            Home e paginas institucionais
assets/           SCSS, JavaScript, fontes e imagens
docs/             Arquitetura, contrato editorial e continuidade
scripts/          Validacoes locais e de CI
tests/            Smoke tests Playwright
```

O contrato editorial e os campos por tipo estao em [`docs/editorial/content-model.md`](docs/editorial/content-model.md). A taxonomia executavel fica em `_data/`, e o fluxo completo esta em [`docs/editorial/publishing.md`](docs/editorial/publishing.md).

A descoberta por tipos, categorias, tags, eventos, relacionados e RSS está documentada em [`docs/editorial/discovery.md`](docs/editorial/discovery.md). Busca permanece fora do produto até o acervo justificar sua adoção.

## Publicacao

1. Crie uma branch a partir de `master`.
2. Adicione `_posts/YYYY-MM-DD-slug.md` com front matter valido.
3. Execute build e testes locais.
4. Abra um Pull Request e aguarde os checks.
5. Apos aprovacao humana, faca merge em `master`.

O GitHub Pages continua responsavel pelo deploy. O workflow de CI valida o site, mas nao publica producao.

## Rollback

Reverta o commit ou merge que introduziu o problema e envie a reversao para `master`:

```bash
git revert <commit>
git push origin master
```

O GitHub Pages recompila o site a partir do estado revertido.

## Contribuicao

- Preserve a identidade preta/verde e o efeito Matrix.
- Nao introduza backend, banco, CMS ou framework de frontend.
- Use HTML semantico e mantenha navegacao por teclado.
- Imagens editoriais precisam de texto alternativo significativo.
- Nao publique diretamente em `master`; use Pull Request.

## GitHub Pages e dominio

O dominio canonico e [https://www.infratips.com.br](https://www.infratips.com.br). O arquivo `CNAME` e a chave `url` de `_config.yml` devem permanecer coerentes.
