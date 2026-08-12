---
title: "Antes de expor um lab Linux: inventarie a superficie de ataque"
summary: "Um inventario simples de servicos, acessos e atualizacoes ajuda a tratar seguranca como parte do laboratorio, nao como um ajuste de ultima hora."
type: article
category: security
tags:
  - security
  - linux
  - hardening
  - labs
status: published
---

## Comece pelo que existe

Um laboratorio pequeno tambem pode expor portas, credenciais ou servicos que voce esqueceu de desligar. Antes de publicar uma porta, encaminhar trafego no roteador ou compartilhar um endereco, faca um inventario curto: qual servico esta em execucao, em qual endereco ele escuta e quem realmente precisa acessa-lo.

Esse levantamento nao e uma auditoria formal nem promete deixar um host seguro. Ele cria uma base observavel para decidir o que manter, restringir ou remover.

## Veja os servicos em escuta

No Linux, comece pela visao de sockets de rede:

```bash
sudo ss -lntup
```

Observe protocolo, porta, endereco de bind e processo. Um servico ligado a `127.0.0.1` atende somente o proprio host; um servico em `0.0.0.0` ou `::` pode aceitar conexoes de outras redes, dependendo do firewall e das rotas. Registre as portas esperadas pelo laboratorio e investigue as que nao reconhece.

Evite usar esse resultado como motivo para abrir tudo no firewall. Uma porta em escuta e apenas uma parte do caminho; acesso externo tambem depende de regras locais, rede, balanceadores e DNS.

## Revise acesso e manutencao

Para cada servico que precisa permanecer, responda perguntas simples:

1. qual e a finalidade dele neste laboratorio;
2. quem precisa acessa-lo e de onde;
3. qual conta administra o host;
4. como atualizar ou desligar o servico de forma reversivel.

No acesso remoto, confirme a configuracao efetiva do SSH antes de mudar uma regra. `sshd -T` ajuda a inspecionar valores resolvidos pelo daemon; mantenha uma sessao administrativa funcional enquanto testa qualquer alteracao. Em producao, siga o processo de mudancas do ambiente em vez de aplicar um comando copiado de um laboratorio.

## Termine com uma pequena evidencia

Guarde no README do laboratorio as portas esperadas, a data da revisao e como reproduzir o teste. Esse registro torna mais facil perceber quando um novo container, proxy ou servico alterou a superficie exposta.

Veja tambem a InfraTip sobre [portas em escuta no Linux]({{ '/verificar-portas-em-escuta-no-linux/' | relative_url }}) e use somente documentacao oficial para regras de firewall ou SSH do seu sistema.

## Referencias

- [Manual do OpenSSH para sshd_config](https://man.openbsd.org/sshd_config)
- [Documentacao do Ubuntu sobre UFW](https://documentation.ubuntu.com/server/how-to/security/firewalls/)
