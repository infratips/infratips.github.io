---
title: "Tutorial: criando um laboratorio Nginx com Docker Compose"
summary: "Suba uma pagina Nginx local, teste a resposta HTTP e pratique um fluxo basico de containers."
type: tutorial
category: cloud-devops
tags:
  - docker
  - containers
  - nginx
  - labs
level: beginner
status: published
---

## Objetivo

Este laboratorio cria um servidor Nginx local usando Docker Compose. O foco nao e decorar comandos: e observar a relacao entre arquivo de configuracao, porta publicada, container e resposta HTTP.

## Pre-requisitos

- Docker Engine instalado e em execucao.
- Docker Compose v2 disponivel pelo comando `docker compose`.
- Uma porta local livre, neste exemplo a `8080`.

## Crie o diretorio do laboratorio

```bash
mkdir -p lab-nginx/site
cd lab-nginx
```

Crie `site/index.html` com um conteudo simples:

```html
<!doctype html>
<html lang="pt-BR">
  <body>
    <h1>InfraTips lab Nginx</h1>
  </body>
</html>
```

Agora crie `compose.yaml`:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./site:/usr/share/nginx/html:ro
```

## Suba e teste

Inicie o container em segundo plano:

```bash
docker compose up -d
docker compose ps
```

Abra `http://localhost:8080` no navegador ou valide pelo terminal:

```bash
curl -i http://localhost:8080
```

A resposta deve ter status `200` e conter `InfraTips lab Nginx`. Para acompanhar o que o processo escreveu no log:

```bash
docker compose logs --follow
```

## O que observar

A porta `8080` pertence ao host e encaminha trafego para a porta `80` do container. O volume monta seu diretorio local como conteudo servido pelo Nginx. A opcao `:ro` deixa o container ler os arquivos, sem poder modifica-los.

Altere o HTML, atualize o navegador e confirme que a mudanca aparece sem recriar a imagem. Isso mostra a diferenca entre uma imagem imutavel e um volume montado durante a execucao.

## Encerramento

Quando terminar, remova o ambiente:

```bash
docker compose down
```

Antes de usar essa estrutura em um servidor, nao exponha portas sem entender firewall, rede e autenticacao. Este laboratorio e intencionalmente local e minimo.

## Referencias

- [Documentacao do Docker Compose](https://docs.docker.com/compose/)
- [Imagem oficial Nginx](https://hub.docker.com/_/nginx)
