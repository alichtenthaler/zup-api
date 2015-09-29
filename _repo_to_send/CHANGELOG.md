# Histórico de mudanças

## 1.0.1 (Em aberto)
### Melhorias
- [Specs] Quebrando spec do apis/cases em vários arquivos para rodar mais rapidamente no CI;
- [Fluxos] O gerenciamento de permissões de etapas agora é feito inteiramente pelo endpoint `PUT /flows/:id/steps/:id/permissions`;
- [Specs] Aumentada cobertura dos models Field e Step;
- [Specs] Atualizado relatório do knapsack;

## Mudancas
- [Flows/Cases] Retornar versão corrente se o fluxo não está em rascunho e foi solicitado um rascunho

### Correções
- [Fluxos/Casos] Bug em Field#add_field_on_step
- [Fluxos/Casos] Bug em Step#set_draft
- [Specs] Factories: Field e Step
- [Gitlab CI] Corrigido build no Gitlab CI e aumentando o número de nodes para 5

## 1.0.0
Versão estável inicial
