FactoryGirl.define do
  factory :group_permission do
    factory :admin_permissions do
      users_full_access true
      inventories_full_access true
      groups_full_access true
      reports_full_access true
      manage_flows true
      inventories_formulas_full_access true
      manage_config true
      panel_access true
      create_reports_from_panel true
    end
  end
end
