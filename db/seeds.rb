require 'ffaker'
require 'cpf_faker'
require 'factory_girl_rails'

#IconUploader.enable_processing = false
#MarkerUploader.enable_processing = false
#PinUploader.enable_processing = false

# encoding: utf-8
fg = FactoryGirl

## Create groups
guest_group = fg.create(:guest_group, name: "Público")
admin = fg.create(:group_for_admin, name: "Admins")

## Users
# Common Users
users = fg.create_list(:user, 10, groups: [guest_group])

# Admins
admins = fg.create_list(:user, 10, groups: [admin])

## Create inventory categories
arvores = fg.create(
  :inventory_category_with_sections, title: "Árvores",
  color: "#78c953"
)
bocas_de_lobo = fg.create(
  :inventory_category_with_sections, title: "Bocas de Lobo",
  color: "#2ab4dc"
)
pracas_wifi = fg.create(
  :inventory_category_with_sections, title: "Praças Wifi",
  color: "#ff6049"
)

arvores_icon = Rails.root.join("public/base/default_icons/icon_arvore@2x.png").open
arvores.update!(
  icon: arvores_icon,
  marker: arvores_icon,
  pin: arvores_icon
)
bocas_de_lobo_icon = Rails.root.join("public/base/default_icons/icon_bocalobo@2x.png").open
bocas_de_lobo.update!(
  icon: bocas_de_lobo_icon,
  marker: bocas_de_lobo_icon,
  pin: bocas_de_lobo_icon
)
wifi_icon = Rails.root.join("public/base/default_icons/icon_pracawifi@2x.png").open
pracas_wifi.update!(
  icon: wifi_icon,
  marker: wifi_icon,
  pin: wifi_icon
)
entulhos_icon = Rails.root.join("public/base/default_icons/icon_coletaentulho@2x.png").open

## Modify forms
section = arvores.sections.build(title: "Outros dados")

section.fields.build(
  title: "return_condition",
  position: 0,
  kind: "text",
  label: "Condição do Retorno"
)
section.fields.build(
  title: "pavimento",
  position: 1,
  kind: "text",
  label: "Levantamento do Pavimento"
)
section.fields.build(
  title: "angle_direction",
  position: 2,
  kind: "text",
  label: "Direção da Inclinação"
)
section.fields.build(
  title: "extra_vegetation",
  position: 3,
  kind: "text",
  label: "Vegetação interferente"
)
section.fields.build(
  title: "angle_inclination",
  position: 4,
  kind: "text",
  label: "Inclinação tronco"
)
section.fields.build(
  title: "leafs_interference",
  position: 5,
  kind: "text",
  label: "Interferência na copa"
)

section.save!

section = bocas_de_lobo.sections.build(title: "Outros dados")

section.fields.build(
  title: "depth",
  position: 0,
  kind: "text",
  label: "Profundidade"
)
section.fields.build(
  title: "type",
  position: 1,
  kind: "text",
  label: "Tipo de Tampa"
)

section = pracas_wifi.sections.build(title: "Outros dados")

section.fields.build(
  title: "max_number_of_conections",
  position: 0,
  kind: "text",
  label: "Número máximo de conexões"
)
section.fields.build(
  title: "wifi_password",
  position: 1,
  kind: "text",
  label: "Senha do Wifi"
)

## Create inventory categories items
arvores_items = boca_de_lobo_items = pracas_wifi_items = []
30.times do
  arvores_items << fg.create(:inventory_item, category: arvores, user: users.sample)
  boca_de_lobo_items << fg.create(:inventory_item, category: bocas_de_lobo, user: users.sample)
  pracas_wifi_items << fg.create(:inventory_item, category: pracas_wifi, user: users.sample)
end

## Create reports categories
limpeza_de_boca = fg.create(:reports_category_with_statuses, title: "Limpeza de Boca", color: bocas_de_lobo.color)
coleta_de_entulho = fg.create(:reports_category_with_statuses, title: "Coleta de Entulho", color: "#ffac2d")

limpeza_de_boca.update!(
  marker: bocas_de_lobo_icon,
  icon: bocas_de_lobo_icon
)
coleta_de_entulho.update!(
  marker: entulhos_icon,
  icon: entulhos_icon
)

# Association reports categories to inventory categories
limpeza_de_boca.inventory_categories << bocas_de_lobo

available_dates = [5.months.ago, 2.months.ago, 29.days.ago, 6.days.ago]

## Create reports items for categories
30.times do
  available_dates.each do |date|
    2.times do
      fg.create(:reports_item, inventory_item: boca_de_lobo_items.sample, category: limpeza_de_boca, created_at: date, user: users.sample)
      fg.create(:reports_item, category: coleta_de_entulho, created_at: date, user: users.sample)
    end
  end
end

# Balance the reports items statuses
statuses_id = Reports::Status.all.map(&:id)

Reports::Item.all.each do |item|
  item.reports_status_id = statuses_id.sample
  item.save!
end
