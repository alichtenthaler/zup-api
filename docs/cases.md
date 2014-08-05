# Documentação ZUP-API - Casos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de um Fluxo completo (com Etapas e Campos) para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/cases`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @case-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/cases
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/cases
```

## Serviços

### Índice

* [Criação](#create)
* [Lista](#list)
* [Exibir](#show)
* [Atualizar](#update)
* [Finalizar](#finish)
* [Transferir para outro Fluxo](#transfer)
* [Inativar](#inactive)
* [Restaurar](#restore)
* [Atualizar Etapa do Caso](#update_case_step)
* [Permissões](#permissions)

___

### Criação <a name="create"></a>

Criação de Caso é feito no envio dos dados da primeira Etapa

Endpoint: `/cases`

Method: post

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                                   |
|-----------------|---------|-------------|-------------------------------------------------------------|
| step_id         | Integer | Sim         | ID do primeiro Step do Fluxo.                               |
| initial_flow_id | Integer | Sim         | ID do Fluxo Inicial (pai de todos fluxos).                  |
| fields          | Array   | Sim         | Array de Hash com ID do Campo e Value com o Valor do campo (a value será convertida no valor correto do campo para verificar as validações do campo). |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 201    | Se foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "step_id": 1,
  "initial_flow_id": 2,
  "fields": [
    {"id": 1, "value": "10"}
  ]
}
```

##### Response

###### Failure
```
Status: 400
Content-Type: application/json
```

```json
{
  "error": {
    "case_steps.fields": [
      "new_age não pode ficar em branco",
      "new_age deve ser maior que 10"
    ]
  }
}
```

###### Success

É criado uma entrado no CasesLogEntries com a ação de 'create_case'.

No retorno de criação do Caso, o retorno é trazido com display_type='full'.

Quando houver um Gatilho que foi executado no final do Caso no retorno vai ter dois valores preenchidos **trigger_values** e **trigger_type**.

**trigger_values** terá o ID do item

**trigger_type** terá um dos valroes: "enable_steps", "disable_steps", "finish_flow", "transfer_flow"

```
Status: 201
Content-Type: application/json
```

```json
{
  "trigger_description": null,
  "trigger_values": null,
  "trigger_type": null,
  "case": {
    "next_step": null,
    "total_steps": 1,
    "flow_version": 4,
    "initial_flow_id": 1,
    "updated_at": "2014-06-07T22:16:15.533-03:00",
    "created_at": "2014-06-07T22:16:15.533-03:00",
    "updated_by": null,
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "facebook_user_id": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "district": "Sao Paulo",
      "postal_code": "18000000",
      "id": 21,
      "name": "Fulano",
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 1
        }
      ],
      "email": "test001@mailinator.com",
      "phone": "123456",
      "document": "57858662775",
      "address": "Rua",
      "address_additional": null
    },
    "id": 2,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      2
    ],
    "next_step_id": null,
    "get_responsible_user": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "57858662775",
      "phone": "123456",
      "email": "test001@mailinator.com",
      "name": "Fulano",
      "reset_password_token": null,
      "salt": "902ad01d9d4767543203f8cdfc99d461",
      "encrypted_password": "db5c8156b7fa81298287f802bc13e993aa7a78ebfbab3924d2e5c6a340081d275bcec708e17eb0504e041ef721b87433fd7de605ca539dd0f68594d1d9c7e24b",
      "id": 21,
      "address": "Rua",
      "address_additional": null,
      "postal_code": "18000000",
      "district": "Sao Paulo",
      "password_resetted_at": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "updated_at": "2014-06-05T00:35:45.743-03:00",
      "facebook_user_id": null
    },
    "original_case": null,
    "case_steps": [
      {
        "updated_at": "2014-06-07T22:16:15.535-03:00",
        "created_at": "2014-06-07T22:16:15.535-03:00",
        "updated_by": null,
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "facebook_user_id": null,
          "created_at": "2014-06-05T00:35:45.743-03:00",
          "district": "Sao Paulo",
          "postal_code": "18000000",
          "id": 21,
          "name": "Fulano",
          "groups": [
            {
              "permissions": {
                "view_categories": "true",
                "view_sections": "true"
              },
              "name": "Público",
              "id": 1
            }
          ],
          "email": "test001@mailinator.com",
          "phone": "123456",
          "document": "57858662775",
          "address": "Rua",
          "address_additional": null
        },
        "id": 2,
        "case_id": 2,
        "step_id": 1,
        "step_version": 1,
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "10",
            "field": {
              "list_versions": null,
              "last_version_id": null,
              "last_version": 1,
              "updated_at": "2014-06-07T22:05:56.799-03:00",
              "created_at": "2014-06-07T22:05:56.799-03:00",
              "active": true,
              "id": 2,
              "title": "xxx",
              "field_type": "integer",
              "filter": null,
              "origin_field": null,
              "category_inventory": null,
              "category_report": null,
              "requirements": {
                "presence": "true",
                "minimum": "10"
              }
            },
            "id": 2
          }
        ],
        "trigger_ids": [],
        "responsible_user_id": 21,
        "responsible_group_id": null
      }
    ]
  },
  "message": "Caso criado com sucesso"
}
```
___

### Lista <a name="list"></a>

Endpoint: `/cases`

Method: get

#### Parâmetros de Entrada

| Nome                 | Tipo    | Obrigatório | Descrição                                                   |
|----------------------|---------|-------------|-------------------------------------------------------------|
| display_type         | String  | Não         | para retornar todos os dados utilizar 'full'.               |
| initial_flow_id      | String  | Não         | Texto de IDs de Fluxo Inicial(separados por ,).             |
| responsible_user_id  | String  | Não         | Texto de IDs de Usuários(separados por ,).                  |
| responsible_group_id | String  | Não         | Texto de IDs de Grupos(separados por ,).                    |
| created_by_id        | String  | Não         | Texto de IDs de Usuários(separados por ,).                  |
| updated_by_id        | String  | Não         | Texto de IDs de Usuários(separados por ,).                  |
| step_id              | String  | Não         | Texto de IDs de Etapas(separados por ,).                    |
| per_page             | Integer | Não         | Quantidade de Casos por páginas.                            |
| page                 | Integer | Não         | Número da página.                                           |

#### Status HTTP

| Código | Descrição                    |
|--------|------------------------------|
| 401    | Acesso não autorizado.       |
| 200    | Se existir um ou mais itens. |

#### Exemplo

##### Request
```json
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "cases": [
    {
      "next_step": null,
      "case_steps": [
        {
          "updated_at": "2014-06-07T22:15:46.722-03:00",
          "created_at": "2014-06-07T22:15:46.722-03:00",
          "updated_by": null,
          "created_by": {
            "google_plus_user_id": null,
            "twitter_user_id": null,
            "facebook_user_id": null,
            "created_at": "2014-06-05T00:35:45.743-03:00",
            "district": "Sao Paulo",
            "postal_code": "18000000",
            "id": 21,
            "name": "Fulano",
            "groups": [
              {
                "permissions": {
                  "view_categories": "true",
                  "view_sections": "true"
                },
                "name": "Público",
                "id": 1
              }
            ],
            "email": "test001@mailinator.com",
            "phone": "123456",
            "document": "57858662775",
            "address": "Rua",
            "address_additional": null
          },
          "id": 1,
          "case_id": 1,
          "step_id": 1,
          "step_version": 1,
          "case_step_data_fields": [
            {
              "case_step_data_attachments": [],
              "case_step_data_images": [],
              "value": "10",
              "field": {
                "list_versions": null,
                "last_version_id": null,
                "last_version": 1,
                "updated_at": "2014-06-07T22:05:56.799-03:00",
                "created_at": "2014-06-07T22:05:56.799-03:00",
                "active": true,
                "id": 2,
                "title": "xxx",
                "field_type": "integer",
                "filter": null,
                "origin_field": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true",
                  "minimum": "10"
                }
              },
              "id": 1
            }
          ],
          "trigger_ids": [],
          "responsible_user_id": 21,
          "responsible_group_id": null
        }
      ],
      "original_case": null,
      "responsible_group": null,
      "responsible_user": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "57858662775",
        "phone": "123456",
        "email": "test001@mailinator.com",
        "name": "Fulano",
        "reset_password_token": null,
        "salt": "902ad01d9d4767543203f8cdfc99d461",
        "encrypted_password": "db5c8156b7fa81298287f802bc13e993aa7a78ebfbab3924d2e5c6a340081d275bcec708e17eb0504e041ef721b87433fd7de605ca539dd0f68594d1d9c7e24b",
        "id": 21,
        "address": "Rua",
        "address_additional": null,
        "postal_code": "18000000",
        "district": "Sao Paulo",
        "password_resetted_at": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "updated_at": "2014-06-05T00:35:45.743-03:00",
        "facebook_user_id": null
      },
      "updated_by": null,
      "total_steps": 1,
      "flow_version": 4,
      "initial_flow_id": 1,
      "updated_at": "2014-06-07T22:15:46.710-03:00",
      "created_at": "2014-06-07T22:15:46.710-03:00",
      "updated_by_id": null,
      "created_by_id": 21,
      "id": 1,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [],
      "case_step_ids": [
        1
      ],
      "next_step_id": null,
      "responsible_user_id": 21,
      "responsible_group_id": null,
      "created_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "facebook_user_id": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "district": "Sao Paulo",
        "postal_code": "18000000",
        "id": 21,
        "name": "Fulano",
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 1
          }
        ],
        "email": "test001@mailinator.com",
        "phone": "123456",
        "document": "57858662775",
        "address": "Rua",
        "address_additional": null
      }
    },
    {
      "next_step": null,
      "case_steps": [
        {
          "updated_at": "2014-06-07T22:16:15.535-03:00",
          "created_at": "2014-06-07T22:16:15.535-03:00",
          "updated_by": null,
          "created_by": {
            "google_plus_user_id": null,
            "twitter_user_id": null,
            "facebook_user_id": null,
            "created_at": "2014-06-05T00:35:45.743-03:00",
            "district": "Sao Paulo",
            "postal_code": "18000000",
            "id": 21,
            "name": "Fulano",
            "groups": [
              {
                "permissions": {
                  "view_categories": "true",
                  "view_sections": "true"
                },
                "name": "Público",
                "id": 1
              }
            ],
            "email": "test001@mailinator.com",
            "phone": "123456",
            "document": "57858662775",
            "address": "Rua",
            "address_additional": null
          },
          "id": 2,
          "case_id": 2,
          "step_id": 1,
          "step_version": 1,
          "case_step_data_fields": [
            {
              "case_step_data_attachments": [],
              "case_step_data_images": [],
              "value": "10",
              "field": {
                "list_versions": null,
                "last_version_id": null,
                "last_version": 1,
                "updated_at": "2014-06-07T22:05:56.799-03:00",
                "created_at": "2014-06-07T22:05:56.799-03:00",
                "active": true,
                "id": 2,
                "title": "xxx",
                "field_type": "integer",
                "filter": null,
                "origin_field": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true",
                  "minimum": "10"
                }
              },
              "id": 2
            }
          ],
          "trigger_ids": [],
          "responsible_user_id": 21,
          "responsible_group_id": null
        }
      ],
      "original_case": null,
      "responsible_group": null,
      "responsible_user": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "57858662775",
        "phone": "123456",
        "email": "test001@mailinator.com",
        "name": "Fulano",
        "reset_password_token": null,
        "salt": "902ad01d9d4767543203f8cdfc99d461",
        "encrypted_password": "db5c8156b7fa81298287f802bc13e993aa7a78ebfbab3924d2e5c6a340081d275bcec708e17eb0504e041ef721b87433fd7de605ca539dd0f68594d1d9c7e24b",
        "id": 21,
        "address": "Rua",
        "address_additional": null,
        "postal_code": "18000000",
        "district": "Sao Paulo",
        "password_resetted_at": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "updated_at": "2014-06-05T00:35:45.743-03:00",
        "facebook_user_id": null
      },
      "updated_by": null,
      "total_steps": 1,
      "flow_version": 4,
      "initial_flow_id": 1,
      "updated_at": "2014-06-07T22:16:15.533-03:00",
      "created_at": "2014-06-07T22:16:15.533-03:00",
      "updated_by_id": null,
      "created_by_id": 21,
      "id": 2,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [],
      "case_step_ids": [
        2
      ],
      "next_step_id": null,
      "responsible_user_id": 21,
      "responsible_group_id": null,
      "created_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "facebook_user_id": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "district": "Sao Paulo",
        "postal_code": "18000000",
        "id": 21,
        "name": "Fulano",
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 1
          }
        ],
        "email": "test001@mailinator.com",
        "phone": "123456",
        "document": "57858662775",
        "address": "Rua",
        "address_additional": null
      }
    }
  ]
}
```
___

### Exibir <a name="show"></a>

Endpoint: `/cases/:id`

Method: get

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                                   |
|-----------------|---------|-------------|-------------------------------------------------------------|
| display_type    | String  | Não         | para retornar todos os dados utilizar 'full'.               |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 404    | Não encontrado.            |
| 200    | Retorna Caso.              |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 404    | Não encontrado.            |
| 200    | Retorna Caso.              |

#### Exemplo

##### Request
```
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "case": {
    "next_step": null,
    "case_steps": [
      {
        "updated_at": "2014-06-07T22:16:15.535-03:00",
        "created_at": "2014-06-07T22:16:15.535-03:00",
        "updated_by": null,
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "facebook_user_id": null,
          "created_at": "2014-06-05T00:35:45.743-03:00",
          "district": "Sao Paulo",
          "postal_code": "18000000",
          "id": 21,
          "name": "Fulano",
          "groups": [
            {
              "permissions": {
                "view_categories": "true",
                "view_sections": "true"
              },
              "name": "Público",
              "id": 1
            }
          ],
          "email": "test001@mailinator.com",
          "phone": "123456",
          "document": "57858662775",
          "address": "Rua",
          "address_additional": null
        },
        "id": 2,
        "case_id": 2,
        "step_id": 1,
        "step_version": 1,
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "10",
            "field": {
              "list_versions": null,
              "last_version_id": null,
              "last_version": 1,
              "updated_at": "2014-06-07T22:05:56.799-03:00",
              "created_at": "2014-06-07T22:05:56.799-03:00",
              "active": true,
              "id": 2,
              "title": "xxx",
              "field_type": "integer",
              "filter": null,
              "origin_field": null,
              "category_inventory": null,
              "category_report": null,
              "requirements": {
                "presence": "true",
                "minimum": "10"
              }
            },
            "id": 2
          }
        ],
        "trigger_ids": [],
        "responsible_user_id": 21,
        "responsible_group_id": null
      }
    ],
    "original_case": null,
    "responsible_group": null,
    "responsible_user": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "57858662775",
      "phone": "123456",
      "email": "test001@mailinator.com",
      "name": "Fulano",
      "reset_password_token": null,
      "salt": "902ad01d9d4767543203f8cdfc99d461",
      "encrypted_password": "db5c8156b7fa81298287f802bc13e993aa7a78ebfbab3924d2e5c6a340081d275bcec708e17eb0504e041ef721b87433fd7de605ca539dd0f68594d1d9c7e24b",
      "id": 21,
      "address": "Rua",
      "address_additional": null,
      "postal_code": "18000000",
      "district": "Sao Paulo",
      "password_resetted_at": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "updated_at": "2014-06-05T00:35:45.743-03:00",
      "facebook_user_id": null
    },
    "updated_by": null,
    "total_steps": 1,
    "flow_version": 4,
    "initial_flow_id": 1,
    "updated_at": "2014-06-07T22:16:15.533-03:00",
    "created_at": "2014-06-07T22:16:15.533-03:00",
    "updated_by_id": null,
    "created_by_id": 21,
    "id": 2,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      2
    ],
    "next_step_id": null,
    "responsible_user_id": 21,
    "responsible_group_id": null,
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "facebook_user_id": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "district": "Sao Paulo",
      "postal_code": "18000000",
      "id": 21,
      "name": "Fulano",
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 1
        }
      ],
      "email": "test001@mailinator.com",
      "phone": "123456",
      "document": "57858662775",
      "address": "Rua",
      "address_additional": null
    }
  }
}
```
___

### Atualizar <a name="update"></a>

Endpoint: `/cases/:id`

Method: put

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                                   |
|-----------------|---------|-------------|-------------------------------------------------------------|
| step_id         | Integer | Sim         | ID do primeiro Step do Fluxo.                               |
| step_version    | Integer | Sim         | Número da versão da Etapa.                                  |
| fields          | Array   | Sim         | Array de Hash com ID do Campo e Value com o Valor do campo (a value será convertida no valor correto do campo para verificar as validações do campo). |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Se foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "step_id": 1,
  "step_version": 1,
  "fields": [
    {"id": 1, "value": "1"}
  ]
}
```

##### Response

###### Failure
```
Status: 400
Content-Type: application/json
```

```json
{
  "error": {
    "case_steps.fields": [
      "new_age deve ser maior que 10"
    ]
  }
}
```

###### Success

É criado uma entrado no CasesLogEntries com a ação de 'next_step' se for uma etapa nova ou 'update_step' se for atualização de uma Etapa já existente no Caso.

No retorno de criação do Caso, o retorno é trazido com display_type='full'.

Se for a última Etapa do Caso o Caso será finalizado e será cirada uma entrada no CasesLogEntries com a ação de 'finished'.

Quando houver um Gatilho que foi executado no final do Caso no retorno vai ter dois valores preenchidos **trigger_values** e **trigger_type**.

**trigger_values** terá o ID do item

**trigger_type** terá um dos valroes: "enable_steps", "disable_steps", "finish_flow", "transfer_flow"

```
Status: 200
Content-Type: application/json
```

```json
{
  "trigger_description": null,
  "trigger_values": null,
  "trigger_type": null,
  "case": {
    "next_step": null,
    "case_steps": [
      {
        "updated_at": "2014-06-07T23:29:30.560-03:00",
        "created_at": "2014-06-07T22:15:46.722-03:00",
        "updated_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "facebook_user_id": null,
          "created_at": "2014-06-05T00:35:45.743-03:00",
          "district": "Sao Paulo",
          "postal_code": "18000000",
          "id": 21,
          "name": "Fulano",
          "groups": [
            {
              "permissions": {
                "view_categories": "true",
                "view_sections": "true"
              },
              "name": "Público",
              "id": 1
            }
          ],
          "email": "test001@mailinator.com",
          "phone": "123456",
          "document": "57858662775",
          "address": "Rua",
          "address_additional": null
        },
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "facebook_user_id": null,
          "created_at": "2014-06-05T00:35:45.743-03:00",
          "district": "Sao Paulo",
          "postal_code": "18000000",
          "id": 21,
          "name": "Fulano",
          "groups": [
            {
              "permissions": {
                "view_categories": "true",
                "view_sections": "true"
              },
              "name": "Público",
              "id": 1
            }
          ],
          "email": "test001@mailinator.com",
          "phone": "123456",
          "document": "57858662775",
          "address": "Rua",
          "address_additional": null
        },
        "id": 1,
        "case_id": 1,
        "step_id": 1,
        "step_version": 1,
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "10",
            "field": {
              "list_versions": null,
              "last_version_id": null,
              "last_version": 1,
              "updated_at": "2014-06-07T22:05:56.799-03:00",
              "created_at": "2014-06-07T22:05:56.799-03:00",
              "active": true,
              "id": 2,
              "title": "xxx",
              "field_type": "integer",
              "filter": null,
              "origin_field": null,
              "category_inventory": null,
              "category_report": null,
              "requirements": {
                "presence": "true",
                "minimum": "10"
              }
            },
            "id": 1
          }
        ],
        "trigger_ids": [],
        "responsible_user_id": 21,
        "responsible_group_id": null
      }
    ],
    "original_case": null,
    "responsible_group": null,
    "responsible_user": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "57858662775",
      "phone": "123456",
      "email": "test001@mailinator.com",
      "name": "Fulano",
      "reset_password_token": null,
      "salt": "902ad01d9d4767543203f8cdfc99d461",
      "encrypted_password": "db5c8156b7fa81298287f802bc13e993aa7a78ebfbab3924d2e5c6a340081d275bcec708e17eb0504e041ef721b87433fd7de605ca539dd0f68594d1d9c7e24b",
      "id": 21,
      "address": "Rua",
      "address_additional": null,
      "postal_code": "18000000",
      "district": "Sao Paulo",
      "password_resetted_at": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "updated_at": "2014-06-05T00:35:45.743-03:00",
      "facebook_user_id": null
    },
    "updated_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "facebook_user_id": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "district": "Sao Paulo",
      "postal_code": "18000000",
      "id": 21,
      "name": "Fulano",
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 1
        }
      ],
      "email": "test001@mailinator.com",
      "phone": "123456",
      "document": "57858662775",
      "address": "Rua",
      "address_additional": null
    },
    "total_steps": 1,
    "flow_version": 4,
    "initial_flow_id": 1,
    "updated_at": "2014-06-07T23:47:36.869-03:00",
    "created_at": "2014-06-07T22:15:46.710-03:00",
    "updated_by_id": 21,
    "created_by_id": 21,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": null,
    "responsible_user_id": 21,
    "responsible_group_id": null,
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "facebook_user_id": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "district": "Sao Paulo",
      "postal_code": "18000000",
      "id": 21,
      "name": "Fulano",
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 1
        }
      ],
      "email": "test001@mailinator.com",
      "phone": "123456",
      "document": "57858662775",
      "address": "Rua",
      "address_additional": null
    }
  },
  "message": "Caso finalizado com sucesso"
}
```
___

### Finalizar <a name="finish"></a>

Para finalizar um Caso antecipadamente.

Endpoint: `/cases/:id/finish`

Method: put

#### Parâmetros de Entrada

| Nome                | Tipo    | Obrigatório | Descrição                              |
|---------------------|---------|-------------|----------------------------------------|
| resolution_state_id | Integer | Sim         | ID do Estado de Resolução para o Caso. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Se foi criado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'finished'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso finalizado com sucesso"
}
```
___

### Transferir para outro Fluxo <a name="transfer"></a>

Endpoint: `/cases/:id/finish`

Method: put

#### Parâmetros de Entrada

| Nome         | Tipo    | Obrigatório | Descrição                                     |
|--------------|---------|-------------|-----------------------------------------------|
| flow_id      | Integer | Sim         | ID do novo Fluxo.                             |
| display_type | String  | Não         | para retornar todos os dados utilizar 'full'. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Se foi criado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'transfer_flow' para o Caso atual e 'create_case' para o novo Caso.

```
Status: 200
Content-Type: application/json
```

```json
{
  "case": {
    "next_step": null,
    "case_steps": [],
    "original_case": {
      "next_step": null,
      "case_steps": [
        {
          "updated_at": "2014-06-07T23:29:30.560-03:00",
          "created_at": "2014-06-07T22:15:46.722-03:00",
          "updated_by": {
            "google_plus_user_id": null,
            "twitter_user_id": null,
            "facebook_user_id": null,
            "created_at": "2014-06-05T00:35:45.743-03:00",
            "district": "Sao Paulo",
            "postal_code": "18000000",
            "id": 21,
            "name": "Fulano",
            "groups": [
              {
                "permissions": {
                  "view_categories": "true",
                  "view_sections": "true"
                },
                "name": "Público",
                "id": 1
              }
            ],
            "email": "test001@mailinator.com",
            "phone": "123456",
            "document": "57858662775",
            "address": "Rua",
            "address_additional": null
          },
          "created_by": {
            "google_plus_user_id": null,
            "twitter_user_id": null,
            "facebook_user_id": null,
            "created_at": "2014-06-05T00:35:45.743-03:00",
            "district": "Sao Paulo",
            "postal_code": "18000000",
            "id": 21,
            "name": "Fulano",
            "groups": [
              {
                "permissions": {
                  "view_categories": "true",
                  "view_sections": "true"
                },
                "name": "Público",
                "id": 1
              }
            ],
            "email": "test001@mailinator.com",
            "phone": "123456",
            "document": "57858662775",
            "address": "Rua",
            "address_additional": null
          },
          "id": 1,
          "case_id": 1,
          "step_id": 1,
          "step_version": 1,
          "case_step_data_fields": [
            {
              "case_step_data_attachments": [],
              "case_step_data_images": [],
              "value": "10",
              "field": {
                "list_versions": null,
                "last_version_id": null,
                "last_version": 1,
                "updated_at": "2014-06-07T22:05:56.799-03:00",
                "created_at": "2014-06-07T22:05:56.799-03:00",
                "active": true,
                "id": 2,
                "title": "xxx",
                "field_type": "integer",
                "filter": null,
                "origin_field": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true",
                  "minimum": "10"
                }
              },
              "id": 1
            }
          ],
          "trigger_ids": [],
          "responsible_user_id": 21,
          "responsible_group_id": null
        }
      ],
      "original_case": null,
      "get_responsible_group": null,
      "get_responsible_user": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "facebook_user_id": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "district": "Sao Paulo",
        "postal_code": "18000000",
        "id": 21,
        "name": "Fulano",
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 1
          }
        ],
        "email": "test001@mailinator.com",
        "phone": "123456",
        "document": "57858662775",
        "address": "Rua",
        "address_additional": null
      },
      "updated_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "facebook_user_id": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "district": "Sao Paulo",
        "postal_code": "18000000",
        "id": 21,
        "name": "Fulano",
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 1
          }
        ],
        "email": "test001@mailinator.com",
        "phone": "123456",
        "document": "57858662775",
        "address": "Rua",
        "address_additional": null
      },
      "total_steps": 1,
      "flow_version": 4,
      "initial_flow_id": 1,
      "updated_at": "2014-06-08T00:54:39.404-03:00",
      "created_at": "2014-06-07T22:15:46.710-03:00",
      "updated_by_id": 21,
      "created_by_id": 21,
      "id": 1,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [
        3
      ],
      "case_step_ids": [
        1
      ],
      "next_step_id": null,
      "responsible_user_id": 21,
      "responsible_group_id": null,
      "created_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "facebook_user_id": null,
        "created_at": "2014-06-05T00:35:45.743-03:00",
        "district": "Sao Paulo",
        "postal_code": "18000000",
        "id": 21,
        "name": "Fulano",
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 1
          }
        ],
        "email": "test001@mailinator.com",
        "phone": "123456",
        "document": "57858662775",
        "address": "Rua",
        "address_additional": null
      }
    },
    "get_responsible_group": null,
    "get_responsible_user": null,
    "updated_by": null,
    "total_steps": 0,
    "flow_version": 1,
    "initial_flow_id": 2,
    "updated_at": "2014-06-08T01:15:16.253-03:00",
    "created_at": "2014-06-08T01:15:16.253-03:00",
    "updated_by_id": null,
    "created_by_id": 21,
    "id": 13,
    "disabled_steps": [],
    "original_case_id": 1,
    "children_case_ids": [],
    "case_step_ids": [],
    "next_step_id": null,
    "responsible_user_id": null,
    "responsible_group_id": null,
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "facebook_user_id": null,
      "created_at": "2014-06-05T00:35:45.743-03:00",
      "district": "Sao Paulo",
      "postal_code": "18000000",
      "id": 21,
      "name": "Fulano",
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 1
        }
      ],
      "email": "test001@mailinator.com",
      "phone": "123456",
      "document": "57858662775",
      "address": "Rua",
      "address_additional": null
    }
  },
  "message": "Caso atualizado com sucesso"
}
```
___

### Inativar <a name="inactive"></a>

Endpoint: `/cases/:id`

Method: delete

#### Parâmetros de Entrada

#### Status HTTP

| Código | Descrição                     |
|--------|-------------------------------|
| 404    | Não encontrado.               |
| 200    | Se foi inativado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'delete_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso removido com sucesso"
}
```
___

### Restaurar <a name="restore"></a>

Endpoint: `/cases/:id/restore`

Method: put

#### Parâmetros de Entrada

#### Status HTTP

| Código | Descrição                      |
|--------|--------------------------------|
| 404    | Não encontrado.                |
| 200    | Se foi restaurado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'restored_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso recuperado com sucesso"
}
```
___

### Atualizar Etapa do Caso <a name="update_case_step"></a>

No momento os únicos valores que podem ser atualizados são 'responsible_user_id' e 'responsible_group_id'.

Endpoint: `/cases/:id/case_steps/:case_step_id`

Method: put

#### Parâmetros de Entrada

| Nome                 | Tipo    | Obrigatório | Descrição                                            |
|----------------------|---------|-------------|------------------------------------------------------|
| responsible_user_id  | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |
| responsible_group_id | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |

#### Status HTTP

| Código | Descrição                      |
|--------|--------------------------------|
| 400    | Parâmetros inválidos.          |
| 401    | Acesso não autorizado.         |
| 200    | Se foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "responsible_user_id": 1
}
```

Se foi enviado alguns dos parametros de responsible será criado uma entrado no CasesLogEntries com a ação de 'transfer_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Estado do Caso atualizado com sucesso"
}
```
___

### Permissões <a name="permissions"></a>

As permissões ficam no Grupo do usuário dentro do atributo permissions.

#### Tipos de Permissões

| Permissão                 | Parâmetro             | Descrição                                                                         |
|---------------------------|-----------------------|-----------------------------------------------------------------------------------|
| can_execute_step          | ID da Etapa           | Pode visualizar e executar/atualizar uma Etapa do Caso.                           |
| can_view_step             | ID da Etapa           | Pode visualizar uma Etapa do Caso.                                                |
| can_execute_all_steps     | ID do Fluxo           | Pode visualizar e executar todas Etapas filhas do Fluxo (filhos diretos).         |
| can_view_all_steps        | ID do Fluxo           | Pode visualizar todas Etapas filhas do Fluxo (filhos diretos).                    |
| flow_can_delete_own_cases | Boolean               | Pode deletar/restaurar Casos Próprios (necessário permissão de visualizar também) |
| flow_can_delete_all_cases | Boolean               | Pode deletar/restaurar qualquer Caso (necessário permissão de visualizar também)  |

___
