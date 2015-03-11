# Documentação ZUP-API - Fluxos - Estados de Resolução

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de um Fluxo para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/resolution_states`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @resolution_states-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/resolution_states
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/resolution_states
```

## Serviços

### Índice

* [Criação](#create)
* [Edição](#update)
* [Deleção](#delete)

___

### Criação <a name="create"></a>

É necessário ter 1 Estado de Resolução como Padrão, caso não tenha o status do Fluxo será como 'pending'

Endpoint: `/flows/:flow_id/resolution_states`

Method: post

#### Parâmetros de Entrada

| Nome     | Tipo    | Obrigatório | Descrição                                            |
|----------|---------|-------------|------------------------------------------------------|
| title    | String  | Sim         | Título do Estado de Resolução. (até 100 caracteres)  |
| default  | Boolean | Não         | Todo Fluxo deve ter um Estado de Resolução padrão    |

#### Status HTTP

| Código | Descrição                                        |
|--------|--------------------------------------------------|
| 400    | Parâmetros inválidos.                            |
| 401    | Acesso não autorizado.                           |
| 201    | Se o Estado de Resolução foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Título do Estado de Resolução",
  "default": true,
}
```

##### Response

##### Failure
```
Status: 400
Content-Type: application/json
```
```json
{
  "error": {
    "default": ["já está em uso]
  }
}
```

##### Success
```
Status: 201
Content-Type: application/json
```

###### ResolutionStateObject
| Nome                  | Tipo       | Descrição                                                                        |
|-----------------------|------------|----------------------------------------------------------------------------------|
| id                    | Interger   | ID do objeto.                                                                    |
| list_versions         | Array      | Array contento todas as versões do objeto.                                       |
| created_at            | DateTime   | Data e horário da criação do objeto.                                             |
| updated_at            | DateTime   | Data e horário da última atualização do objeto.                                  |
| title                 | String     | Título do Objeto.                                                                |
| active                | Boolean    | Se o objeto esta ativo.                                                          |
| default               | Boolean    | Se é o Estado de Resolução padrão ou não (apenas um padrão por Fluxo)            |
| version_id            | Interger   | ID da Versão do objeto.                                                          |

```json
{
  "resolution_state": {
    "list_versions": null,
    "created_at": "2015-03-04T02:08:10.302-03:00",
    "updated_at": "2015-03-04T02:08:10.302-03:00",
    "version_id": null,
    "active": true,
    "default": true,
    "title": "Resolução 1",
    "id": 1
  },
  "message": "Estado de Resolução criado com sucesso"
}
```
___

### Edição <a name="update"></a>

Endpoint: `/flows/:flow_id/resolution_states/:id`

Method: put

#### Parâmetros de Entrada

| Nome     | Tipo    | Obrigatório | Descrição                                            |
|----------|---------|-------------|------------------------------------------------------|
| title    | String  | Sim         | Título do Estado de Resolução. (até 100 caracteres)  |
| default  | Boolean | Não         | Todo Fluxo deve ter um Estado de Resolução padrão    |

#### Status HTTP

| Código | Descrição                                            |
|--------|------------------------------------------------------|
| 400    | Parâmetros inválidos.                                |
| 401    | Acesso não autorizado.                               |
| 404    | Etapa não existe.                                    |
| 200    | Se o Estado de Resolução foi atualizado com sucesso. |

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
  "message": "Estado de Resolução atualizado com sucesso"
}
```
___

### Deleção <a name="delete"></a>

Endpoint: `/flows/:flow_id/resolution_states/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai desse Estado de Resolução (pode ver com a opção GET do Fluxo e o atributo "total_cases")
o Estado de Resolução não poderá ser apagada e será inativada, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                                         |
|--------|---------------------------------------------------|
| 401    | Acesso não autorizado.                            |
| 404    | Estado de Resolução não existe.                   |
| 200    | Se o Estado de Resolução foi apagado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Estado de Resolução apagado com sucesso"
}
```
