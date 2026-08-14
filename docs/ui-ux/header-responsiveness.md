# Responsividade do cabecalho

## Objetivo

Manter navegacao, redes sociais, controles de leitura e marca utilizaveis sem sobreposicao em qualquer largura suportada.

## Solucao atual

O terminal tem largura maxima propria, portanto o cabecalho usa uma container query baseada em sua largura real, e nao apenas na largura da janela. No terminal limitado, os textos das redes sociais e dos controles sao ocultados visualmente. Em uma faixa ainda menor, tambem somem os textos da navegacao principal; icones, `aria-label`, `title` e alvos minimos de 44 px continuam disponiveis.

Em tablet e celular, o fluxo existente distribui os grupos em mais de uma linha.

## Arquivos

- `_includes/header.html`: estrutura semantica e rotulos acessiveis.
- `assets/css/main.scss`: layout, container queries e breakpoints.
- `tests/site.spec.js`: regressao contra intersecao entre links e botoes visiveis.

## Validacao

O teste renderizado mede os retangulos dos controles do cabecalho e falha quando dois alvos visiveis ocupam a mesma area.

## Roadmap

Correcao incremental de UX posterior a P3.1; nao altera arquitetura, modelo editorial ou publicacao.
