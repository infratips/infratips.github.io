---
title: "Transforme um laboratorio em evidencia tecnica com um README"
summary: "Um README curto registra objetivo, comandos e resultados para que um laboratorio possa ser revisado, reproduzido e explicado com clareza."
type: tip
category: fundamentals-career
tags:
  - career
  - labs
  - documentation
  - portfolio
level: beginner
status: published
---

Um laboratorio vale mais quando voce consegue explicar o que tentou, o que observou e como outra pessoa pode repetir a experiencia. Um README simples faz esse trabalho sem transformar cada exercicio em um projeto grande.

Comece com cinco blocos:

1. **Objetivo:** qual pergunta tecnica o laboratorio responde.
2. **Pre-requisitos:** sistema, ferramentas e portas locais usadas.
3. **Passos:** comandos essenciais na ordem em que foram executados.
4. **Evidencia:** saida esperada, captura ou teste que confirma o resultado.
5. **Limpeza e proximo passo:** como encerrar o ambiente e o que voce quer explorar depois.

Evite registrar senhas, tokens, IPs privados de terceiros ou dados de producao. Se uma configuracao depender de valor sensivel, descreva a variavel e forneca um exemplo ficticio. Tambem registre falhas relevantes: um erro diagnosticado com clareza mostra mais aprendizado do que uma sequencia de comandos sem contexto.

Use este modelo no [laboratorio Nginx com Docker Compose]({{ '/laboratorio-nginx-com-docker-compose/' | relative_url }}) ou na [checagem HTTP com Python]({{ '/verificar-endpoint-http-com-python/' | relative_url }}). O objetivo nao e montar um portfolio artificial; e manter evidencia honesta do que voce praticou e consegue discutir.
