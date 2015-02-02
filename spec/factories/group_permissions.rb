FactoryGirl.define do
  factory :group_permission do
    factory :admin_permissions do
      manage_users true
      manage_inventory_categories true
      manage_inventory_items true
      manage_groups true
      manage_reports_categories true
      manage_reports true
      manage_flows true
      manage_inventory_formulas true
      manage_config true
      panel_access true
      create_reports_from_panel true
      edit_reports true
      edit_inventory_items true
    end
  end
end
