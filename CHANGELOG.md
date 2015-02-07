# CHANGELOG

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

