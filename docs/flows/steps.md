# Documentação ZUP-API - Fluxos - Etapas

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de um Fluxo para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @steps-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps
```

## Serviços

### Índice

* [Listagem](#list)
* [Criação](#create)
* [Edição](#update)
* [Exibir](#show)
* [Deleção](#delete)
* [Redefinir Ordenação](#order)
* [Adicionar Permissão](#permission_add)
* [Remover Permissão](#permission_rem)

___

### Exibir <a name="show"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição              |
|--------|------------------------|
| 401    | Acesso não autorizado. |
| 404    | Não encontrado.        |
| 200    | Exibe Etapa.           |

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
  "step": {
    "list_versions": null,
    "last_version_id": null,
    "last_version": 1,
    "id": 2,
    "title": "Titulo da Etapa 3",
    "step_type": "flow",
    "child_flow": {
      "last_version_id": null,
      "last_version": 1,
      "step_id": null,
      "status": "active",
      "id": 5,
      "title": "Novo Titulo 2",
      "description": "Agora com descrição",
      "created_by_id": 308,
      "updated_by_id": null,
      "initial": false,
      "created_at": "2014-04-11T17:45:24.829-03:00",
      "updated_at": "2014-04-11T17:45:24.829-03:00"
    },
    "fields": [
    {
      "last_version_id": null,
      "last_version": 1,
      "order_number": 1,
      "requirements": null,
      "filter": null,
      "multiple": false,
      "updated_at": "2014-05-17T13:40:18.039-03:00",
      "created_at": "2014-05-17T13:40:18.039-03:00",
      "id": 1,
      "title": "age",
      "field_type": "integer",
      "category_inventory_id": null,
      "category_report_id": null,
      "origin_field_id": null,
      "active": true,
      "step_id": 1
    }
    ],
      "order_number": 2,
      "active": true,
      "created_at": "2014-05-16T15:22:18.408-03:00",
      "updated_at": "2014-05-16T15:22:18.408-03:00"
  }
}
```
___

### Listagem de Etapas <a name="list"></a>

Endpoint: `/flows/:flow_id/steps`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição                                    |
|--------|----------------------------------------------|
| 401    | Acesso não autorizado.                       |
| 200    | Exibe listagem de Etapas (com zero ou mais). |

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
  "steps": [
  {
    "list_versions": null,
      "last_version_id": null,
      "last_version": 1,
      "id": 1,
      "title": "Titulo da Etapa 2",
      "step_type": "form",
      "child_flow": null,
      "order_number": 1,
      "active": true,
      "created_at": "2014-05-16T15:19:59.430-03:00",
      "updated_at": "2014-05-16T15:19:59.430-03:00"
  },
  {
    "list_versions": null,
    "last_version_id": null,
    "last_version": 1,
    "id": 2,
    "title": "Titulo da Etapa 3",
    "step_type": "flow",
    "child_flow": {
      "last_version_id": null,
      "last_version": 1,
      "step_id": null,
      "status": "active",
      "id": 5,
      "title": "Novo Titulo 2",
      "description": "Agora com descrição",
      "created_by_id": 308,
      "updated_by_id": null,
      "initial": false,
      "created_at": "2014-04-11T17:45:24.829-03:00",
      "updated_at": "2014-04-11T17:45:24.829-03:00"
    },
    "fields": [
    {
      "last_version_id": null,
      "last_version": 1,
      "order_number": 1,
      "requirements": null,
      "filter": null,
      "multiple": false,
      "updated_at": "2014-05-17T13:40:18.039-03:00",
      "created_at": "2014-05-17T13:40:18.039-03:00",
      "id": 1,
      "title": "age",
      "field_type": "integer",
      "category_inventory_id": null,
      "category_report_id": null,
      "origin_field_id": null,
      "active": true,
      "step_id": 1
    }
    ],
      "order_number": 2,
      "active": true,
      "created_at": "2014-05-16T15:22:18.408-03:00",
      "updated_at": "2014-05-16T15:22:18.408-03:00"
  }
  ]
}
```
___

### Redefinir Ordenação das Etapas <a name="order"></a>

Endpoint: `/flows/:flow_id/steps`

Method: put

#### Parâmetros de Entrada

| Nome | Tipo  | Obrigatório | Descrição                                   |
|------|-------|-------------|---------------------------------------------|
| ids  | Array | Sim         | Array com ids das Etapas na ordem desejada. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Exibe mensagem de sucesso. |

#### Exemplo

##### Request

```json
{
  "ids": [3,1,2]
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Ordem das Etadas atualizada com sucesso"
}
```
___

### Criação de Etapa <a name="create"></a>

Endpoint: `/flows/:flow_id/steps`

Method: post

#### Parâmetros de Entrada

| Nome               | Tipo    | Obrigatório | Descrição                                                           |
|--------------------|---------|-------------|---------------------------------------------------------------------|
| title              | String  | Sim         | Título da Etapa. (até 100 caracteres)                               |
| step_type          | String  | Sim         | Tipo da Etapa. (Fluxo=flow ou Formulário=form)                      |
| child_flow_id      | Integer | Não         | Se step_type for flow é necessário informar o id do Fluxo filho     |
| child_flow_version | Integer | Não         | Se step_type for flow é necessário informar a versão do Fluxo filho |

#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 400    | Parâmetros inválidos.              |
| 401    | Acesso não autorizado.             |
| 201    | Se a Etapa foi criada com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Título da Etapa",
  "step_type": "flow",
  "child_flow_id": 1,
  "child_flow_version": 1,
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

```json
{
  "step": {
    "list_versions": null,
    "last_version_id": null,
    "last_version": 1,
    "updated_at": "2014-06-06T21:54:11.936-03:00",
    "id": 3,
    "title": "Titulo da Etapa Fluxo",
    "step_type": "flow",
    "child_flow": {
      "list_versions": null,
      "total_cases": 0,
      "updated_at": "2014-06-06T21:25:17.483-03:00",
      "created_at": "2014-06-06T21:25:17.483-03:00",
      "last_version_id": null,
      "last_version": 1,
      "status": "pending",
      "id": 2,
      "title": "Outro Fluxo",
      "description": "Descrição",
      "initial": false,
      "steps": [],
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
      "updated_by": null,
      "resolution_states": []
    },
    "fields": [],
    "order_number": 3,
    "active": true,
    "created_at": "2014-06-06T21:54:11.936-03:00"
  },
  "message": "Etapa criada com sucesso"
}
```
___

### Edição da Etapa <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: put

#### Parâmetros de Entrada

| Nome               | Tipo    | Obrigatório | Descrição                                                           |
|--------------------|---------|-------------|---------------------------------------------------------------------|
| title              | String  | Sim         | Título da Etapa. (até 100 caracteres)                               |
| step_type          | String  | Sim         | Tipo da Etapa. (Fluxo=flow ou Formulário=form)                      |
| child_flow_id      | Integer | Não         | Se step_type for flow é necessário informar o id do Fluxo filho     |
| child_flow_version | Integer | Não         | Se step_type for flow é necessário informar a versão do Fluxo filho |

#### Status HTTP

| Código | Descrição                              |
|--------|----------------------------------------|
| 400    | Parâmetros inválidos.                  |
| 401    | Acesso não autorizado.                 |
| 404    | Etapa não existe.                      |
| 200    | Se a Etapa foi atualizada com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título da Etapa"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Etapa atualizada com sucesso"
}
```
___

### Deleção <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai da Etapa desse Gatilho (pode ver com a opção GET do Fluxo e o atributo "total_cases")
o Gatilho não poderá ser apagado e será inativado, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                             |
|--------|---------------------------------------|
| 401    | Acesso não autorizado.                |
| 404    | Gatilho não existe.                   |
| 200    | Se o Gatilho foi apagada com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Gatilho apagado com sucesso"
}
```

___

### Adicionar Permissão <a name="permission_add"></a>

Endpoint: `/flows/:flow_id/steps/:id/permissions`

Method: put

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser adicionado.            |

#### Tipos de Permissões

| Permissão                 | Parâmetro             | Descrição                                                                         |
|---------------------------|-----------------------|-----------------------------------------------------------------------------------|
| can_execute_step          | ID da Etapa           | Pode visualizar e executar/atualizar uma Etapa do Caso.                           |
| can_view_step             | ID da Etapa           | Pode visualizar uma Etapa do Caso.                                                |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 400    | Permissão não existe.   |
| 401    | Acesso não autorizado.  |
| 404    | Não existe.             |
| 200    | Atualizado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  message: "Permissões atualizadas com sucesso"
}
```

___

### Remover Permissão <a name="permission_rem"></a>

Endpoint: `/flows/:flow_id/steps/:id/permissions`

Method: delete

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser removida.              |

#### Tipos de Permissões

| Permissão                 | Parâmetro             | Descrição                                                                         |
|---------------------------|-----------------------|-----------------------------------------------------------------------------------|
| can_execute_step          | ID da Etapa           | Pode visualizar e executar/atualizar uma Etapa do Caso.                           |
| can_view_step             | ID da Etapa           | Pode visualizar uma Etapa do Caso.                                                |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 400    | Permissão não existe.   |
| 401    | Acesso não autorizado.  |
| 404    | Não existe.             |
| 200    | Atualizado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  message: "Permissões atualizadas com sucesso"
}
```
