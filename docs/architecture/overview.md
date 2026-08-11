# Arquitetura do InfraTips

## Estado atual

O InfraTips e um site estatico gerado por Jekyll. Markdown com front matter YAML entra pelo Git, layouts Liquid produzem HTML, SCSS gera o estilo e JavaScript puro executa a interface e o efeito Matrix. O GitHub Pages publica o resultado de `master` no dominio `www.infratips.com.br`.

```text
Markdown + _data
        |
        v
Jekyll + Liquid + SCSS
        |
        v
HTML/CSS/JavaScript estatico
        |
        v
GitHub Pages
```

Nao existem backend, banco de dados, CMS, login ou servico de busca. Git e a fonte de verdade, Pull Request e a fronteira de revisao e o merge em `master` continua sendo a autorizacao de publicacao.

## Componentes editoriais

- `_posts/`: conteudos publicados de todos os tipos editoriais.
- `_data/`: tipos, categorias, niveis, status e labels controlados.
- `_layouts/post.html`: base compartilhada de conteudo.
- `_includes/content_details.html`: metadados comuns e variacoes de noticia/evento.
- `_layouts/home.html` e `_includes/home_discovery.html`: descoberta na home.
- `_layouts/archive.html`: pagina compartilhada para tipos e categorias.
- `_includes/related_content.html`: relacionados por tipo, categoria ou tags.
- `_config.yml`: defaults visuais e editoriais derivados.
- `scripts/validate_content.rb`: anti-drift deterministico antes do build.

O plugin `jekyll-feed`, já pertencente ao conjunto suportado pelo GitHub Pages, gera o RSS geral. Busca permanece fora da arquitetura atual.

Collections permanecem fora do escopo. Uma mudanca futura so se justifica se volume, URL, ciclo de vida ou templates exigirem comportamento diferente de `_posts/`.

## Limites preservados

A identidade Matrix, Jekyll, GitHub Pages, Markdown e a ausencia de infraestrutura de servidor sao restricoes do produto. P1 e P2 alteram contrato editorial e descoberta, mas nao mudam hospedagem, deploy ou arquitetura de execucao no navegador.
