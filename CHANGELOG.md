# CHANGELOG

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

