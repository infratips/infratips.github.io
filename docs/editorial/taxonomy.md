# Taxonomia editorial

Tipo descreve o formato editorial. Categoria descreve o dominio principal. Tag adiciona detalhes livres e controlados por convencao. Nivel informa dificuldade somente quando aplicavel.

Os IDs e labels executaveis ficam em:

- `_data/types.yml`;
- `_data/categories.yml`;
- `_data/levels.yml`;
- `_data/statuses.yml`;
- `_data/event_modes.yml` e `_data/event_states.yml` para apresentacao de eventos.

Templates e validadores devem consultar esses arquivos em vez de espalhar labels ou enums pelo codigo.

## Escolha pratica

- Use exatamente um `type` e uma `category` por conteudo.
- Use poucas tags especificas, em minusculas e sem sinonimos duplicados.
- Nao transforme tecnologias pontuais em categorias sem necessidade editorial recorrente.
- Carreira permanece assunto da categoria de fundamentos, nao um tipo.
- Certificacoes, provedores e ferramentas funcionam inicialmente como tags.

Alterar `_data` muda o contrato executavel. A mesma mudanca deve revisar este documento e exemplos relacionados quando houver impacto de significado.
