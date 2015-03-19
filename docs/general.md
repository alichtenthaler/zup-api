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
