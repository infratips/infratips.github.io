---
title: "Encontrando diretorios que consomem espaco no Linux"
summary: "Use du e sort para localizar rapidamente os diretorios que mais ocupam espaco em um filesystem."
type: tip
category: linux-open-source
tags:
  - linux
  - storage
  - troubleshooting
level: beginner
status: published
---

## Contexto

Quando um servidor fica sem espaco, apagar arquivos aleatoriamente e uma forma rapida de piorar o incidente. Primeiro, descubra qual parte do filesystem cresceu.

## Comando

Para listar o consumo dos diretorios diretamente dentro de `/var`:

```bash
sudo du -xh --max-depth=1 /var | sort -h
```

O `du` calcula o uso em disco. `--max-depth=1` limita a visao ao primeiro nivel, e `sort -h` ordena tamanhos como MB e GB corretamente.

Repita o comando no diretorio que apareceu no topo da lista. Por exemplo, se `/var/log` estiver grande:

```bash
sudo du -xh --max-depth=1 /var/log | sort -h
```

## Cuidado

Uso alto em `/var` pode vir de logs, cache de pacotes, imagens de containers ou arquivos temporarios. Identifique o responsavel antes de remover qualquer arquivo. Tambem confirme em qual filesystem voce esta trabalhando com `df -h`.

## Referencia

Consulte `man du` e `man df` no sistema para conhecer as opcoes disponiveis na distribuicao usada.
