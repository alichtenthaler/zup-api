# CHANGELOG

## v1.4.2-p20

* Correção na busca de usuários
* Correção na criação de relato
* Correção nas permissões dos grupos
* Correção nos valores do histórico de inventário
* Adicionada entrada no histórico quando um relato entra em atraso

## v1.4.2-p15
* Correções na integração com webhook
* Correção no histórico de inventário
* Adicionada nova feature flag para limitação geoespacial

## v1.4.2-p12
* Correção na busca utilizando filtros de itens de inventário

## v1.4.2-p11
* Correções nos fluxos
* Correções na clusterização de relatos
* Correções na busca de itens de inventário
* Correções ao salvar um item de inventário
* Melhoria de performance para fórmulas

## v1.4.2-p5
* Correção ao adicionar permissões

## v1.4.2-p4
* Integração via webhook
* Correções nos mapas
* Correções nos gatilhos de item de inventário
* Correção na criação e atualização de item de inventário
* Melhoras no histórico de inventário

## v1.4.1-p0
* Nova estrutura de permissões
* Mudanças na clusterização
* Mudança do webserver para usar o Phusion Passenger
* Atualização de dependências
* Ruby 2.2.1
* Otimizações de performance
* Correções para gatilhos dos itens de inventário
* Adicionado padronização do código fonte
* Utilização do Dockerfile para configuração de ambiente


## v1.1.1-p6

* Correções para campos de inventário com múltipla escolha
* Correção para permissões de grupo com referências inválidas
* Atualização de dependência para aumento de performance geral nos endpoints

## v1.1.1-p2

* Correções de ambiente de variáveis
* Agora há validações para as variáveis de ambiente

## v1.1.1-p1

* [FIX] Corrigido bug que evitava status ser criado/alterado como privado
* Simplificação de variáveis de ambiente relacinadas à URLs da aplicação

## v1.1.0-p1
* [NEW] Clusterização para relatos e inventários
* [NEW] Adicionado nova estrutura para opções de campos do tipo checkbox, radio e select.
* [NEW] Adicionado histórico para item de inventário e relato
* [NEW] Adicionado nova estrutura para buscar permissões para os grupos
* [FIX] Corrigido vários erros de validação para os campos de inventário
* [FIX] Coerção de datas para a busca de relatos e inventários
* [FIX] Correções de fluxos e casos
* [UPDATE] Atualizada a versão de dependências

## v1.0.0-p1

* [FIX] Corrige `sidekiq-cron` integração
* [FIX] Corrige bug onde usuários com permissão de gerenciar
categorias de inventário podiam listar todas as categorias de relato

## v1.0.0

Essa é a primeira versão do ZUP, estamos iniciando o versionamento neste release.

Este release inclui:

* [FIX] Evita erro ao atualizar um item de inventário se houver inconsistência no banco
* [FIX] Corrige busca por item de inventário quando usando certas combinações de data e outros filtros
* Permite comentários nos relatos
* Migração de tarefas que rodam em background (`whenever` para `sidekiq-cron`)
* Adiciona `database.yml` específico para o Codeship
* Filtro de seções e campos de inventário baseado nas permissões do usuário
* Permissões para categorias de inventário agora são gravadas de forma atomica no Postgres (gem `atomic-arrays`)
* Desativa seções e seus campos ao invés de destruí-los

