---
title: "Validando Terraform antes do apply"
summary: "Use formatacao, validacao e plano para reduzir erros simples antes de alterar infraestrutura."
type: tip
category: cloud-devops
tags:
  - terraform
  - iac
  - cloud
  - devops
level: beginner
status: published
---

## Contexto

O comando `terraform apply` pode alterar recursos reais. Uma rotina curta antes do apply diminui erros de sintaxe, variaveis ausentes e mudancas inesperadas.

## Comandos

Na raiz do modulo Terraform, execute:

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
```

`fmt -check` mostra arquivos que precisam ser formatados. `init` baixa providers e modulos declarados. `validate` verifica a configuracao local, e `plan` apresenta as alteracoes pretendidas.

Para aplicar a formatacao antes de revisar o diff:

```bash
terraform fmt -recursive
git diff --check
```

## Cuidado

Um `plan` valido nao substitui revisao humana. Confira recursos que serao destruidos ou recriados, o provider e a conta Cloud usada pelo terminal. Em automacoes, mantenha o mesmo conjunto de variaveis e credenciais usado no ambiente alvo.

## Referencia

Consulte a documentacao oficial dos comandos [`validate`](https://developer.hashicorp.com/terraform/cli/commands/validate) e [`plan`](https://developer.hashicorp.com/terraform/cli/commands/plan).
