# Zeladoria Urbana Participativa - API

## Introdução

Sabemos que o manejo de informação é uma das chaves para uma gestão eficiente, para isso o ZUP apresenta um completo histórico de vida de cada um dos ativos e dos problemas do município, incorporando solicitacões de cidadãos, dados georeferenciados, laudos técnicos, fotografias e ações preventivas realizadas ao longo do tempo. Desta forma, o sistema centraliza todas as informações permitindo uma rápida tomada de decisões tanto das autoridades como dos técnicos em campo.

Esse componente é toda a base do processamento de informação do ZUP, atuando como o ponto final de consumo de todos os componentes envolvidos no produto:

* Aplicativo Android e iOS para munícipes
* Aplicativo web para munícipes
* Aplicativo Android para gestão de inventário
* Painel administrativo web

## Tecnologias

O ZUP-API é um projeto escrito em Ruby com diversos componentes e bibliotecas.

## Instalação

**Observação:** Esse README informa como subir o projeto em ambiente para desenvolvimento. Para informações sobre como fazer o deploy do projeto para produção, leia o [Guia de instalação](http://docs.zup.ntxdev.com.br/site/installation_docker/).

Para instalar o ZUP na sua máquina, para desenvolvimento, você precisará:

* Postgres 9.4+
* Postgis 2.1+
* ImageMagick 6.8+
* Redis 2.8.9
* Ruby 2.2.1
* GEOS

## Instale as bibliotecas

Após instalada essas dependências, vamos instalar as bibliotecas, rode o seguinte comando na raiz do projeto:

    bundle install

## Configuração do ambiente

Após ter instalado essas bibliotecas, você precisa configurar as variáveis de ambiente para a aplicação funcionar corretamente.

Abrindo o arquivo `sample.env` na raiz do projeto você tem todas as variáveis de ambiente disponíveis para a configuração do projeto.
Copie este arquivo para a raiz do projeto com o nome `.env` e preencha pelo menos as variáveis que são obrigatórias para o funcionamento do componente:

* `API_URL` - URL completa na qual a API responderá (incluir a porta, caso não seja a porta 80)
* `SMTP_ADDRESS` - Endereço do servidor de SMTP para envio de email
* `SMTP_PORT` - Porta do servidor de SMTP
* `SMTP_USER` - Usuário para autenticação do SMTP
* `SMTP_PASS` - Senha para autenticação do SMTP
* `SMTP_TTLS` - Configuração TTLS para o SMTP
* `SMTP_AUTH` - Configuração do modo de autenticação do SMTP
* `REDIS_URL` - URL onde o servidor Redis está ouvindo (ex.: redis://10.0.0.1:6379)
* `WEB_URL` - A URL completa da URL onde o componente ZUP-PAINEL está rodando

## Configuração inicial do banco de dados

Após configurar as variáveis de ambiente no arquivo `.env`, você estará pronto para configurar o banco de dados.

Primeiramente, copie o arquivo `config/database.yml.sample` para `config/database.yml` e modifique com os dados do seu Postgres.

Feito isso, faça o _setup_ do banco de dados:

    rake db:setup

**Ao final desse comando será gerado um usuário e senha de administrador, anote-os em um lugar seguro, você precisará dele para logar no sistema pela primeira vez.**

Para iniciar o servidor, você só precisa executar o seguinte comando:

    bundle exec foreman start -f Procfile.dev

Se tudo estiver ok, este deverá ser o seu output:

```
12:05:22 web.1    | started with pid 63360
12:05:22 worker.1 | started with pid 63361
12:05:23 web.1    | =============== Phusion Passenger Standalone web server started ===============
12:05:23 web.1    | PID file: /Users/user/projects/zup-api/passenger.3000.pid
12:05:23 web.1    | Log file: /Users/user/projects/zup-api/log/passenger.3000.log
12:05:23 web.1    | Environment: development
12:05:23 web.1    | Accessible via: http://0.0.0.0:3000/
12:05:23 web.1    |
12:05:23 web.1    | You can stop Phusion Passenger Standalone by pressing Ctrl-C.
12:05:23 web.1    | Problems? Check https://www.phusionpassenger.com/library/admin/standalone/troubleshooting/
12:05:23 web.1    | ===============================================================================
12:05:25 web.1    | App 63391 stdout:
12:05:29 worker.1 | /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: already initialized constant Mapquest::API_ROOT
12:05:29 worker.1 | /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: previous definition of API_ROOT was here
12:05:29 worker.1 | 2015-09-23T15:05:29.390Z 63361 TID-owtng2518 INFO: Booting Sidekiq 3.4.2 with redis options {:url=>"redis://127.0.0.1:6379", :namespace=>"zup"}
12:05:29 worker.1 | 2015-09-23T15:05:29.431Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: unlock_inventory_items
12:05:29 worker.1 | 2015-09-23T15:05:29.437Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: set_reports_overdue
12:05:29 worker.1 | 2015-09-23T15:05:29.443Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: expire_access_keys
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Running in ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: See LICENSE and the LGPL-3.0 for licensing details.
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Upgrade to Sidekiq Pro for more features and support: http://sidekiq.org/pro
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Starting processing, hit Ctrl-C to stop
12:05:30 web.1    | App 63391 stderr: /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: already initialized constant Mapquest::API_ROOT
12:05:30 web.1    | App 63391 stderr: /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: previous definition of API_ROOT was here
12:05:31 web.1    | App 63411 stdout:
```

Você poderá acessar a seguinte URL para certificar-se que o servidor subiu corretamente:

[](http://127.0.0.1:3000/feature_flags)

Está pronto! Para maiores informações sobre os componentes internos da API, leia os documentos escritos na pasta `docs/` que pode ser encontrada na raiz do projeto.

