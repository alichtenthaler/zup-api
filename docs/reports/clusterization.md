# Clusterização dos Relatos

No endpoint `GET /search/reports/items` você pode pedir a versão clusterizada quando buscando pelo mapa, para isso, basta passar `clusterize: true` nos parâmetros:

    ...
    &clusterize=true

## Retorno

Quando você passar esse parâmetro, o JSON de resposta que será retornado terá uma estrutura diferente:

    {
      "clusters": [...]
      "reports": [...]
    }

### Clusters

Os **clusters** são entidades mais simples que representam um conjunto de relatos, seus atributos são os seguintes:

    {
      "reports_ids": [1, 2, 3],
      "position": [-23.5546875, -46.636962890625],
      "category": { ... }, // Categoria de relato
      "count": 3
    }

* `reports_ids` são os ids dos relatos que estão sendo representados
* `position` são as coordenadas geográficas das categorias de relato
* `category` é a entidade de categoria de relato daquele relato
* `count` é o número de relatos que o cluster está representando
