# Documentação ZUP-API - Fluxos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @flows-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows
```

## Serviços

### Índice

* [Listagem de Fluxos](#list)
* [Criação de Fluxo](#create)
* [Exibir Fluxo](#show)
* [Edição de Fluxo](#update)
* [Deleção de Fluxo](#delete)
* [Adicionar Permissão](#permission_add)
* [Remover Permissão](#permission_rem)

___

### Listagem de Fluxos <a name="list"></a>

Endpoint: `/flows`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| initial       | Boolena | Não         | Para retornar Fluxos que forem iniciais.       |
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição                                    |
|--------|----------------------------------------------|
| 401    | Acesso não autorizado.                       |
| 200    | Exibe listagem de fluxos (com zero ou mais). |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "flows": [
    {
      "list_versions": null,
      "total_cases": 0,
      "updated_at": "2014-04-11T13:43:53.707-03:00",
      "created_at": "2014-04-11T13:43:53.707-03:00",
      "last_version_id": null,
      "last_version": 1,
      "id": 2,
      "title": "xxx",
      "description": null,
      "steps": [
        {
          "child_flow_version": null,
          "child_flow_id": null,
          "last_version_id": null,
          "last_version": 1,
          "active": true,
          "id": 1,
          "title": "Titulo da Etapa 2",
          "description": null,
          "step_type": "form",
          "flow_id": 2,
          "created_at": "2014-05-16T15:19:59.430-03:00",
          "updated_at": "2014-05-16T15:19:59.430-03:00",
          "order_number": 1
        },
        {
          "child_flow_version": 1,
          "child_flow_id": 5,
          "last_version_id": null,
          "last_version": 1,
          "active": true,
          "id": 2,
          "title": "Titulo da Etapa 3",
          "description": null,
          "step_type": "flow",
          "flow_id": 2,
          "created_at": "2014-05-16T15:22:18.408-03:00",
          "updated_at": "2014-05-16T15:22:18.408-03:00",
          "order_number": 2
        }
      ],
      "created_by": {
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 3
          }
        ],
        "name": "Fulano",
        "id": 308
      },
      "updated_by": null,
      "resolution_states": [
        {
          "last_version_id": null,
          "id": 1,
          "flow_id": 2,
          "title": "Titulo da Etapa 2",
          "default": false,
          "active": true,
          "created_at": "2014-05-16T15:05:33.705-03:00",
          "updated_at": "2014-05-16T15:05:33.705-03:00",
          "last_version": 1
        }
      ],
      "status": "active"
    },
    {
      "list_versions": null,
      "total_cases": 0,
      "updated_at": "2014-04-11T13:44:33.266-03:00",
      "created_at": "2014-04-11T13:44:33.266-03:00",
      "last_version_id": null,
      "last_version": 1,
      "id": 3,
      "title": "xxx",
      "description": null,
      "steps": [],
      "created_by": {
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 3
          }
        ],
        "name": "Fulano",
        "id": 308
      },
      "updated_by": null,
      "resolution_states": [],
      "status": "active"
    },
    {
      "list_versions": null,
      "total_cases": 0,
      "updated_at": "2014-04-11T17:45:24.829-03:00",
      "created_at": "2014-04-11T17:45:24.829-03:00",
      "last_version_id": null,
      "last_version": 1,
      "id": 5,
      "title": "Novo Titulo 2",
      "description": "Agora com descrição",
      "steps": [],
      "created_by": {
        "groups": [
          {
            "permissions": {
              "view_categories": "true",
              "view_sections": "true"
            },
            "name": "Público",
            "id": 3
          }
        ],
        "name": "Fulano",
        "id": 308
      },
      "updated_by": null,
      "resolution_states": [],
      "status": "active"
    }
  ]
}
```
___

### Criação de Fluxo <a name="create"></a>

Endpoint: `/flows`

Method: post

#### Parâmetros de Entrada

| Nome        | Tipo    | Obrigatório | Descrição                                |
|-------------|---------|-------------|------------------------------------------|
| title       | String  | Sim         | Título do Fluxo. (até 100 caracteres)    |
| description | Text    | Não         | Descrição do Fluxo. (até 600 caracteres) |
| initial     | Boolean | Não         | Para definir um Fluxo como inicial.      |

#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 400    | Parâmetros inválidos.              |
| 401    | Acesso não autorizado.             |
| 201    | Se o Fluxo foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Título do Fluxo",
  "description": "Descrição para o Fluxo"
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

```json
{
  "flow": {
    "list_versions": null,
    "total_cases": 0,
    "updated_at": "2014-05-16T15:43:04.427-03:00",
    "created_at": "2014-05-16T15:43:04.427-03:00",
    "last_version_id": null,
    "last_version": 1,
    "id": 6,
    "title": "Titulo do Fluxo",
    "description": "Descrição do Fluxo",
    "steps": [],
    "created_by": {
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 3
        }
      ],
      "name": "Fulano",
      "id": 308
    },
    "updated_by": null,
    "resolution_states": [],
    "status": "pending"
  },
  "message": "Fluxo criado com sucesso"
}
```
___

### Edição de Fluxo <a name="update"></a>

Endpoint: `/flows/:id`

Method: put

#### Parâmetros de Entrada

| Nome        | Tipo    | Obrigatório | Descrição                                |
|-------------|---------|-------------|------------------------------------------|
| title       | String  | Sim         | Título do Fluxo. (até 100 caracteres)    |
| description | Text    | Não         | Descrição do Fluxo. (até 600 caracteres) |
| initial     | Boolean | Não         | Para definir um Fluxo como inicial.      |

#### Status HTTP

| Código | Descrição                              |
|--------|----------------------------------------|
| 400    | Parâmetros inválidos.                  |
| 401    | Acesso não autorizado.                 |
| 404    | Fluxo não existe.                      |
| 200    | Se o Fluxo foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título do Fluxo"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Fluxo atualizado com sucesso"
}
```
___

### Deleção de Fluxo <a name="delete"></a>

Endpoint: `/flows/:id`

Method: delete

Se houver algum Caso criado para o Fluxo (pode ver com a opção GET do Fluxo e o atributo "total_cases")
o Fluxo não poderá ser apagado e será inativado, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                            |
|--------|--------------------------------------|
| 401    | Acesso não autorizado.               |
| 404    | Fluxo não existe.                    |
| 200    | Se o Fluxo foi apagado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Fluxo apagado com sucesso"
}
```
___

### Exibir Fluxo <a name="show"></a>

Endpoint: `/flows/:id`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 401    | Acesso não autorizado.  |
| 404    | Fluxo não existe.       |
| 200    | Exibe o Fluxo buscado.  |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "flow": {
    "list_versions": null,
    "total_cases": 0,
    "updated_at": "2014-04-11T13:43:53.707-03:00",
    "created_at": "2014-04-11T13:43:53.707-03:00",
    "last_version_id": null,
    "last_version": 1,
    "id": 2,
    "title": "xxx",
    "description": null,
    "steps": [
      {
        "child_flow_version": null,
        "child_flow_id": null,
        "last_version_id": null,
        "last_version": 1,
        "active": true,
        "id": 1,
        "title": "Titulo da Etapa 2",
        "description": null,
        "step_type": "form",
        "flow_id": 2,
        "created_at": "2014-05-16T15:19:59.430-03:00",
        "updated_at": "2014-05-16T15:19:59.430-03:00",
        "order_number": 1
      },
      {
        "child_flow_version": 1,
        "child_flow_id": 5,
        "last_version_id": null,
        "last_version": 1,
        "active": true,
        "id": 2,
        "title": "Titulo da Etapa 3",
        "description": null,
        "step_type": "flow",
        "flow_id": 2,
        "created_at": "2014-05-16T15:22:18.408-03:00",
        "updated_at": "2014-05-16T15:22:18.408-03:00",
        "order_number": 2
      }
    ],
    "created_by": {
      "groups": [
        {
          "permissions": {
            "view_categories": "true",
            "view_sections": "true"
          },
          "name": "Público",
          "id": 3
        }
      ],
      "name": "Fulano",
      "id": 308
    },
    "updated_by": null,
    "resolution_states": [
      {
        "last_version_id": null,
        "id": 1,
        "flow_id": 2,
        "title": "Titulo da Etapa 2",
        "default": false,
        "active": true,
        "created_at": "2014-05-16T15:05:33.705-03:00",
        "updated_at": "2014-05-16T15:05:33.705-03:00",
        "last_version": 1
      }
    ],
    "status": "active"
  }
}
```

___

### Adicionar Permissão <a name="permission_add"></a>

Endpoint: `/flows/:id/permissions`

Method: put

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser adicionado.            |

#### Tipos de Permissões

| Permissão                  | Parâmetro             | Descrição                                                                         |
|----------------------------|-----------------------|-----------------------------------------------------------------------------------|
| flow_can_execute_all_steps | ID do Fluxo           | Pode visualizar e executar todas Etapas filhas do Fluxo (filhos diretos).         |
| flow_can_view_all_steps    | ID do Fluxo           | Pode visualizar todas Etapas filhas do Fluxo (filhos diretos).                    |
| flow_can_delete_own_cases  | Boolean               | Pode deletar/restaurar Casos Próprios (necessário permissão de visualizar também) |
| flow_can_delete_all_cases  | Boolean               | Pode deletar/restaurar qualquer Caso (necessário permissão de visualizar também)  |

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

Endpoint: `/flows/:id/permissions`

Method: delete

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser removida.              |

#### Tipos de Permissões

| Permissão                  | Parâmetro             | Descrição                                                                         |
|----------------------------|-----------------------|-----------------------------------------------------------------------------------|
| flow_can_execute_all_steps | ID do Fluxo           | Pode visualizar e executar todas Etapas filhas do Fluxo (filhos diretos).         |
| flow_can_view_all_steps    | ID do Fluxo           | Pode visualizar todas Etapas filhas do Fluxo (filhos diretos).                    |
| flow_can_delete_own_cases  | Boolean               | Pode deletar/restaurar Casos Próprios (necessário permissão de visualizar também) |
| flow_can_delete_all_cases  | Boolean               | Pode deletar/restaurar qualquer Caso (necessário permissão de visualizar também)  |

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
