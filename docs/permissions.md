# Permissões

Para adicionar (ou remover) permissões de um grupo, utilizar o seguinte endpoint com o id do grupo:

`PUT /groups/1/permissions`

## Permissões de administração

Existem as seguintes permissões disponíveis para administração.
Seus valores são booleanos (true/false) e ela sobrepõe qualquer outra permissão
do grupo:

```
manage_users
manage_inventory_categories
manage_inventory_items
manage_groups
manage_reports_categories
manage_reports
manage_flows
view_categories
view_sections
```

Podem ser passadas como parâmetros, exemplo:

    {
      "manage_users": true,
      "manage_groups": false
    }


## Permissões para seções de categorias

Utilizar os seguintes identificadores: `inventory_sections_can_view` e `inventory_sections_can_edit`

Exemplo de requisição:

    {
      "inventory_sections_can_view": [1,2,3,4],
      "inventory_sections_can_edit": [1,3,4,5]
    }

## Permissões para campos de categorias de inventário

Utilizar os seguintes identificadores: `inventory_fields_can_view` e `inventory_fields_can_edit`

Exemplo de requisição:

    {
      "inventory_fields_can_view": [1,2,3,4],
      "inventory_fields_can_edit": [1,4,6,5]
    }
