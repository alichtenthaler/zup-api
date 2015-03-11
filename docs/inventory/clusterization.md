# Clusterização dos Itens de Inventário

No endpoint `GET /search/inventory/items` você pode pedir a versão clusterizada quando buscando pelo mapa, para isso, basta passar `clusterize: true` nos parâmetros:

    ...
    &clusterize=true

## Retorno

Quando você passar esse parâmetro, o JSON de resposta que será retornado terá uma estrutura diferente:

    {
      "clusters": [...]
      "items": [...]
    }

### Clusters

Os **clusters** são entidades mais simples que representam um conjunto de itens de inventário, seus atributos são os seguintes:

    {
      "items_ids": [1, 2, 3],
      "position": [-23.5546875, -46.636962890625],
      "category": { ... }, // Categoria de inventário
      "count": 3
    }

* `items_ids` são os ids dos itens de inventário que estão sendo representados
* `position` são as coordenadas geográficas das categorias de relato
* `category` é a entidade de categoria de relato daquele relato
* `count` é o número de itens de inventário que o cluster está representando
