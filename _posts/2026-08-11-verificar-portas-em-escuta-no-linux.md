---
title: "Como verificar portas em escuta no Linux"
summary: "Use o comando ss para identificar serviços que aguardam conexões TCP ou UDP."
type: tip
category: linux-open-source
tags:
  - linux
  - networking
level: beginner
status: published
---

## Contexto

Ao investigar um serviço indisponível, primeiro confirme se algum processo está aguardando conexões na porta esperada.

## Comando

```bash
ss -lntup
```

As opções mostram sockets em escuta (`-l`), conexões TCP (`-t`) e UDP (`-u`), endereços numéricos (`-n`) e o processo associado (`-p`). Para procurar uma porta específica:

```bash
ss -lntup | grep ':443'
```

## Cuidado

Informações de processos pertencentes a outros usuários podem exigir privilégios administrativos. Encontrar uma porta em escuta confirma o estado local do socket, mas não garante que firewall, regras de Cloud ou roteamento permitam acesso externo.

## Referência

Consulte a documentação local com `man ss`.
