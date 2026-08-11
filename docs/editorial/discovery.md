# Descoberta de conteúdo

## Home

A home é um índice editorial, não uma landing page comercial. Sua ordem atual é:

1. descrição curta do InfraTips;
2. entradas leves de "Comece aqui";
3. conteúdos recentes;
4. InfraTips;
5. próximos eventos;
6. materiais e canais;
7. fundador em posição secundária.

Os caminhos de "Comece aqui" apontam para categorias existentes. A curadoria sequencial de trilhas pertence à P3 e não deve ser simulada automaticamente por tags.

## Diretórios

`/conteudo/` oferece navegação por tipo e categoria. Cada ID controlado em `_data/types.yml` e `_data/categories.yml` possui exatamente um arquivo fino em `pages/archives/`, renderizado pelo layout compartilhado `archive`.

`/conteudo/tags/` mantém um índice único de tags. Não são geradas centenas de páginas individuais. `/eventos/` separa agenda futura e histórico a partir de `starts_at`, sem banco de dados.

## Conteúdo relacionado

Páginas editoriais podem apresentar até três conteúdos relacionados. A seleção percorre a cronologia existente e aceita correspondência por categoria, tipo ou tag compartilhada. Se não houver correspondência real, a seção não é exibida.

## RSS

O feed geral está em `/feed.xml` e usa `jekyll-feed`. Todos os posts publicados entram no mesmo feed, incluindo eventos, para manter uma única cronologia previsível no volume atual.

## Busca

Busca não está implementada. Quando o acervo atingir aproximadamente 30–50 conteúdos, Pagefind deve ser reavaliado como índice estático gerado no build. Até lá, tipos, categorias, tags e recentes resolvem o problema de descoberta com menos dependências e complexidade.
