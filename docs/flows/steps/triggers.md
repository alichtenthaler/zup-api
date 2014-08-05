# Documentação ZUP-API - Fluxos - Etapas - Gatilhos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de uma Etapa para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @trigger-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers
```

## Serviços

### Índice

* [Listagem](#list)
* [Criação](#create)
* [Edição](#update)
* [Deleção](#delete)
* [Redefinir Ordenação](#order)

___

### Listagem <a name="list"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 401    | Acesso não autorizado.             |
| 200    | Exibe listagem (com zero ou mais). |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "triggers": [
    {
      "list_versions": null,
      "last_version_id": null,
      "last_version": 1,
      "updated_at": "2014-05-16T21:02:20.360-03:00",
      "id": 1,
      "title": "Titulo",
      "trigger_conditions": [
        {
          "list_versions": null,
          "id": 1,
          "field": null,
          "condition_type": "==",
          "values": [
            1
          ],
          "last_version": 1,
          "last_version_id": null,
          "created_at": "2014-05-16T21:02:20.384-03:00",
          "updated_at": "2014-05-16T21:02:20.384-03:00"
        }
      ],
      "action_type": "disable_steps",
      "action_values": [
        1
      ],
      "order_number": 1,
      "active": true,
      "created_at": "2014-05-16T21:02:20.360-03:00"
    }
  ]
}
```
___

### Redefinir Ordenação <a name="order"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: put

#### Parâmetros de Entrada

| Nome | Tipo  | Obrigatório | Descrição                                     |
|------|-------|-------------|-----------------------------------------------|
| ids  | Array | Sim         | Array com ids dos Gatilhos na ordem desejada. |

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
  "message": "Ordem dos Gatilhos atualizado com sucesso"
}
```
___

### Criação <a name="create"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: post

#### Parâmetros de Entrada

| Nome                          | Tipo    | Obrigatório | Descrição                                                            |
|-------------------------------|---------|-------------|----------------------------------------------------------------------|
| title                         | String  | Sim         | Título. (até 100 caracteres)                                         |
| action_type                   | String  | Sim         | Tipo da ação. (enable_steps disable_steps finish_flow transfer_flow) |
| action_values                 | Array   | Sim         | Array com ids variando conforme o action_type                        |
| trigger_conditions_attributes | Array   | Sim         | Condições do Gatilho (vide TriggerConditionsAttributes)              |


##### TriggerConditionsAttributes
| Nome           | Tipo    | Obrigatório | Descrição                                                                     |
|----------------|---------|-------------|-------------------------------------------------------------------------------|
| field_id       | Integer | Sim         | ID do Campo que irá ser utilizado                                             |
| condition_type | String  | Sim         | Tipo da condição (== != > < inc)                                              |
| values         | Array   | Sim         | Array de valor(es) para ser comparado (apenas "inc" utiliza mais de um valor) |

#### Status HTTP

| Código | Descrição                            |
|--------|--------------------------------------|
| 400    | Parâmetros inválidos.                |
| 401    | Acesso não autorizado.               |
| 201    | Se o Gatilho foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title":"Titulo",
  "action_values":[1],
  "action_type":"disable_steps",
  "trigger_conditions_attributes":[
    {"field_id":1, "condition_type":"==", "values":[1]}
  ]
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

```json
{
  "trigger": {
    "list_versions": null,
    "last_version_id": null,
    "last_version": 1,
    "updated_at": "2014-05-16T21:02:20.360-03:00",
    "id": 1,
    "title": "Titulo",
    "trigger_conditions": [
      {
        "list_versions": null,
        "id": 1,
        "field": null,
        "condition_type": "==",
        "values": [
          1
        ],
        "last_version": 1,
        "last_version_id": null,
        "created_at": "2014-05-16T21:02:20.384-03:00",
        "updated_at": "2014-05-16T21:02:20.384-03:00"
      }
    ],
    "action_type": "disable_steps",
    "action_values": [
      1
    ],
    "order_number": 1,
    "active": true,
    "created_at": "2014-05-16T21:02:20.360-03:00"
  },
  "message": "Gatilho criado com sucesso"
}
```
___

### Edição <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers/:id`

Method: put

#### Parâmetros de Entrada

| Nome                          | Tipo    | Obrigatório | Descrição                                                            |
|-------------------------------|---------|-------------|----------------------------------------------------------------------|
| title                         | String  | Sim         | Título. (até 100 caracteres)                                         |
| action_type                   | String  | Sim         | Tipo da ação. (enable_steps disable_steps finish_flow transfer_flow) |
| action_values                 | Array   | Sim         | Array com ids variando conforme o action_type                        |
| trigger_conditions_attributes | Array   | Sim         | Condições do Gatilho (vide TriggerConditionsAttributes)              |


##### TriggerConditionsAttributes
| Nome           | Tipo    | Obrigatório | Descrição                                                                     |
|----------------|---------|-------------|-------------------------------------------------------------------------------|
| id             | Integer | Não         | ID do trigger_condition já existe ou vazio se for novo                        |
| field_id       | Integer | Sim         | ID do Campo que irá ser utilizado                                             |
| condition_type | String  | Sim         | Tipo da condição (== != > < inc)                                              |
| values         | Array   | Sim         | Array de valor(es) para ser comparado (apenas "inc" utiliza mais de um valor) |

#### Status HTTP

| Código | Descrição                                |
|--------|------------------------------------------|
| 400    | Parâmetros inválidos.                    |
| 401    | Acesso não autorizado.                   |
| 404    | Gatilho não existe.                      |
| 200    | Se o Gatilho foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Gatilho atualizado com sucesso"
}
```
___

### Deleção da Etapa <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai dessa Etapa (pode ver com a opção GET do Fluxo e o atributo "total_cases")
a Etapa não poderá ser apagada e será inativada, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                           |
|--------|-------------------------------------|
| 401    | Acesso não autorizado.              |
| 404    | Etapa não existe.                   |
| 200    | Se a Etapa foi apagada com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Etapa apagada com sucesso"
}
```
___

### Exibir Etapa <a name="show"></a>

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
| 404    | Etapa não existe.      |
| 200    | Exibe a Etapa buscada. |

#### Exemplo

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
    "id": 3,
    "title": "Titulo da Etapa 4",
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
    "order_number": 3,
    "active": true,
    "created_at": "2014-05-16T17:01:54.699-03:00",
    "updated_at": "2014-05-16T17:01:54.699-03:00"
  }
}
```
