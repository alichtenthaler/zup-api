# Considerações gerais

## Escolher campos de retorno

Em todos os endpoints de listagem (ex: grupos, itens de inventário, relatos, categories, etc), você tem a opção de escolher quais campos deseja retornar da API, para isto basta utilizar o parâmetro `return_fields` na sua requisição.

Supomos que você queria o seguinte conteúdo para itens de inventário:

    {
      items: [
        {
          id: 1,
          title: 'Árvores',
          user: {
            id: 1,
            name: 'Ricardo'
          }
        },
        {
          id: 2,
          title: 'Semáforos',
          user: {
            id: 2,
            name: 'Rita'
          }
        }
      ]
    }

Você deverá passar o seguinte parâmetro pra URL do endpoint:

```
/inventory/items?return_fields=id,title,user.id,user.name
```

Nota-se que o formato é *uma string com os nomes dos campos separados por vírgulas*.
Também, para conteúdos aninhados, você deve utilizar o separador `.`, por exemplo, o campo `user.groups.name` é válido.

## Erros

Em diversos momentos e casos é esperado que a API retorne erros. Basicamente, quando ocorre um erro, o status HTTP de resposta da requisição é diferente de `200`.

O formato da resposta de erro retornada pela API é a seguinte:

    {
      "error": "...", // Pode ser uma string com a mensagem de erro ou um objeto
      "type": "..." // Tipo do erro
    }

### Status HTTP

Os seguintes status de erro retornados pela API é:

#### 403
A requisição falhou por falta de permissão.

#### 401
A requisição falhou por problemas de parâmetros.

#### 404
Algum objeto necessário não foi encontrado para a resposta da requisição ser construída.

#### 400
Problemas de validação de lógica de negócio.

### Tipos de erros

#### Não encontrado (not_found)

Caso alguma entidade necessária para a resposta da requisição não ter sido encontrada, um erro será retornado, com o `type: "not_found"`.

Exemplo de resposta:

    {
      "type": "not_found",
      "error": "Não foi encontrado"
    }

#### Erro de validação

Caso ocorra um erro de validação relacionado ao modelo de negócio, um erro do tipo `type: "model_validation"` será retornado. Comumente no atributo `"error"` virá um objeto com os campos com falhas na validação.

Exemplo de resposta:

    {
      "type": "model_validation",
      "error": {
        "name": "está vazio"
      }
    }

#### Erro de permissão

Caso o usuário logado não esteja autorizado a realizar a ação proposta pela requisição, será retornado um erro com o `type` igual a `invalid_permission`.

Exemplo de resposta:

    {
      "type": "invalid_permission",
      "error": "Usuário não pode editar: grupo"
    }

#### Erro desconhecido

Caso ocorra um erro desconhecido a resposta virá com o `type` igual a `unknown` e o `error` será a mensagem de erro:

Exemplo de resposta:

    {
      "type": "unknown",
      "error": "Erro desconhecido ocorreu, contate o suporte"
    }
