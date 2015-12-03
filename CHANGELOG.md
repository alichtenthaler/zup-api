# Histórico de mudanças

## 1.1.1 - 27/11/2015
### Correções
- [Relatos] Correção no agendamento da tarefa para extrair dados do EXIFF


## 1.1.0 - 20/11/2015
### Adições
- [Relatos] Adicionado filtro de perímetros para pesquisa de relatos
- [Perímetros] Adicionado pesquisa por título e ordenação para o endpoint dos perímetros
- [Perímetros] Adicionado grupo solucionador padrão para os perímetros

### Mudanças
- [Relatos/Históricos] Adicionado novo tipo de histórico para identificar quando um relato é encaminhado para um perímetro

### Correções
- [Testes] Corrigido testes que falhavam aleatoriamente
- [Notificações] Alterado notificações para o prazo padrão aceitar valores nulos
- [Notificações] Adicionado categoria do relato no retorno da pesquisa de notificações

### Correções
- [Relatos] Corrigido pesquisa por dias em atraso para notificações vencidas

### Correções
- Corrigido traduções para português

### Correções
- [Etapas] Alterado etapas para listar os gatilhos na ordem correta

### Correções
- [Gatilhos] Corrige a atualização de gatilhos e condições

## 1.0.6
### Mudanças
- Atualização da dependência dos trabalhos assíncronos

## 1.0.5
## Mudanças
- [Relatos/Perímetros] Alterada paginação de perímetros para opcional

### Correções
- [Usuários] Alterado a data de nascimento para opcional no cadastro de usuário

## 1.0.4
## Adições
- [Relatos] Adicionada a funcionalidade de Perímetros
- [Usuários] Adicionado campos extras
- [Fluxos] Corrige problema que impedia a exibição de campos permissionados na listagem de todos os campos de um Fluxo

## Mudanças
- [Notificações] Alterado notificações para o prazo padrão poder ser opcional
- [Relatos] Alterado placeholder de endereço para usar o endereço completo ao invés de somente o logradouro
- [Relatos] Alterado pesquisa de endereço para filtrar pelos campos de logradouro, bairro e CEP

### Correções
- [Usuários] Adicionado validação de confirmação de senha

## 1.0.3
## Adições
- Adicionado legenda e data para as imagens dos relatos

### Correções
- [Relatos] Normalizado tempo de resposta na pesquisa de notificações

## 1.0.2
## Adições
- Adicionada nova funcionalidade de notificações para as categorias de relato

### Melhorias
- [Specs] Quebrando spec do apis/cases em vários arquivos para rodar mais rapidamente no CI;
- [Fluxos] O gerenciamento de permissões de etapas agora é feito inteiramente pelo endpoint `PUT /flows/:id/steps/:id/permissions`;
- [Specs] Aumentada cobertura dos models Field e Step;
- [Specs] Atualizado relatório do knapsack;
- [Casos] Parâmetros de pesquisa e filtragem em listagem de casos;

## Mudanças
- [Fluxos/Casos] Retornar versão corrente se o fluxo não está em rascunho e foi solicitado um rascunho
- [Relatos] Criar histórico quando a referência de um relato for alterada

### Correções
- [Fluxos/Casos] Bug em Field#add_field_on_step
- [Fluxos/Casos] Bug em Step#set_draft
- [Specs] Factories: Field e Step
- [Gitlab CI] Corrigido build no Gitlab CI e aumentando o número de nodes para 5
- [Relatos/Relatórios] Corrigido diferença de quantidade de relatos encontrados entre os Relatórios e a pesquisa de Relatos
- [Relatos/Categorias] Corrigido a listagem de categorias privadas, que estavam sendo exibidas para os usuários não-logados

## 1.0.0
Versão estável inicial
