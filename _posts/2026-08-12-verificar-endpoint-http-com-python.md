---
title: "Automatizando uma checagem HTTP com Python"
summary: "Um script pequeno com a biblioteca padrao do Python transforma uma verificacao manual de endpoint em um teste repetivel para laboratorios e automacoes."
type: tutorial
category: programming-ai
tags:
  - python
  - automation
  - http
  - observability
level: beginner
status: published
---

## Objetivo

Verificar uma URL pelo navegador e util durante um teste rapido. Quando a mesma checagem precisa acontecer varias vezes, um script deixa claro qual URL foi testada, qual status voltou e qual falha precisa ser investigada.

Este exemplo usa somente a biblioteca padrao do Python. Ele e apropriado para um laboratorio ou para uma verificacao simples; monitoramento de producao exige alertas, historico e tratamento de dependencias mais completo.

## Crie o script

Salve o arquivo como `check_http.py`:

```python
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def check(url):
    request = Request(url, headers={"User-Agent": "InfraTips-lab-check/1.0"})
    try:
        with urlopen(request, timeout=10) as response:
            print(f"OK {response.status} {response.url}")
            return 0
    except HTTPError as error:
        print(f"HTTP {error.code} {url}")
        return 1
    except URLError as error:
        print(f"ERRO de rede: {error.reason}")
        return 2


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("uso: python3 check_http.py https://exemplo.local/")
    raise SystemExit(check(sys.argv[1]))
```

## Execute contra um endpoint permitido

```bash
python3 check_http.py https://www.infratips.com.br/
```

Uma resposta `OK 200` indica que a requisicao HTTP terminou com sucesso. Um `HTTP 404` mostra que o servidor respondeu, mas o recurso nao existe; um erro de rede aponta para DNS, conexao, TLS ou indisponibilidade antes de haver uma resposta HTTP.

Teste tambem uma aplicacao local que voce controla:

```bash
python3 -m http.server 8000
python3 check_http.py http://127.0.0.1:8000/
```

Use uma segunda janela para manter o servidor local em execucao. Pare o processo ao terminar com `Ctrl+C`.

## Evolua sem esconder falhas

O codigo sai com status diferente de zero quando a verificacao falha. Isso permite usa-lo em um script de laboratorio ou em uma automacao simples. Antes de adicionar autenticacao, tokens ou URLs internas, prefira variaveis de ambiente e nunca grave segredos no arquivo ou no historico do terminal.

Se usar uma ferramenta de IA para propor timeout, repeticao ou novos testes, trate a resposta como uma hipotese: revise o diff, confirme as APIs na documentacao oficial e execute primeiro contra um endpoint controlado. Nao envie tokens, URLs internas ou respostas com dados sensiveis ao prompt. A evidencia continua sendo o comportamento reproduzido pelo script, nao a explicacao gerada pela ferramenta.

Para diagnosticar uma falha, combine o resultado com a [experiencia de conectividade por camadas]({{ '/aplicacao-funciona-localmente-mas-nao-externamente/' | relative_url }}). O script prova somente a requisicao feita a partir da maquina onde ele foi executado.

## Referencias

- [Python: urllib.request](https://docs.python.org/3/library/urllib.request.html)
- [Python: tratamento de excecoes](https://docs.python.org/3/tutorial/errors.html)
