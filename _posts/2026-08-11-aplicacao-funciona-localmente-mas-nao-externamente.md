---
title: "Experiencia de campo: aplicacao funciona no servidor, mas nao externamente"
summary: "Um diagnostico por camadas evita culpar a aplicacao quando o problema esta em porta, firewall, rede ou balanceador."
type: experience
category: cloud-devops
tags:
  - troubleshooting
  - networking
  - cloud
  - observability
status: published
---

## Contexto

Um padrao recorrente em ambientes Linux e Cloud ocorre quando a aplicacao responde em `localhost`, mas usuarios externos recebem timeout ou conexao recusada. A primeira reacao costuma ser alterar a aplicacao. Na pratica, o erro pode estar em qualquer camada entre o processo e o cliente.

Este relato resume um roteiro de diagnostico que pode ser aplicado a ambientes de laboratorio e producao, sempre respeitando as mudancas aprovadas para o ambiente.

## Problema

O servico respondia localmente:

```bash
curl -i http://127.0.0.1:8080
```

Mas uma requisicao a partir de outra maquina nao recebia resposta. O sintoma era insuficiente para concluir se a aplicacao, o host ou a rede estava errado.

## Diagnostico

O primeiro passo foi confirmar em qual endereco o processo estava ouvindo:

```bash
ss -lntup | grep ':8080'
```

Um servico vinculado somente a `127.0.0.1` aceita conexoes locais, mas nao recebe trafego em um endereco de rede do host. Quando ele esta em `0.0.0.0` ou no IP correto, a investigacao segue para o firewall local, regras de seguranca Cloud, rotas, balanceador e DNS.

Tambem e importante diferenciar timeout de conexao recusada. Timeout sugere bloqueio ou caminho inexistente. Conexao recusada normalmente indica que o destino foi alcancado, mas nao havia processo aceitando naquela porta.

## Solucao

O roteiro que reduziu tentativas aleatorias foi:

1. testar a aplicacao em `localhost`;
2. verificar socket, porta e endereco de bind;
3. testar pelo IP privado a partir de uma maquina na mesma rede;
4. revisar firewall do host e regras do provedor;
5. validar balanceador, DNS e TLS quando existirem;
6. registrar a camada em que o trafego deixou de passar.

Cada teste deve alterar uma unica variavel. Assim, a equipe consegue provar o que foi corrigido e evita abrir portas ou permissoes desnecessarias.

## Resultado

Com a sequencia, o problema deixa de ser "a aplicacao nao abre" e passa a ser uma hipotese mensuravel. O tempo de diagnostico diminui porque cada comando elimina uma camada inteira de possibilidades.

## Licoes

- acesso local nao valida acessibilidade externa;
- uma porta em escuta nao confirma regra de firewall ou roteamento;
- logs e testes de rede devem acompanhar mudancas de configuracao;
- checklists simples ajudam profissionais iniciantes a diagnosticar com mais seguranca.

Veja tambem a InfraTip sobre [portas em escuta no Linux]({{ '/verificar-portas-em-escuta-no-linux/' | relative_url }}).
