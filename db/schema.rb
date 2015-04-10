# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150409234826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "postgis"
  enable_extension "postgis_topology"

  create_table "access_keys", force: true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.boolean  "expired",    default: false, null: false
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_keys", ["key"], :name => "index_access_keys_on_key"
  add_index "access_keys", ["user_id"], :name => "index_access_keys_on_user_id"

  create_table "case_step_data_attachments", force: true do |t|
    t.string   "attachment"
    t.string   "file_name"
    t.integer  "case_step_data_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_step_data_attachments", ["case_step_data_field_id"], :name => "index_case_step_data_attachments_on_case_step_data_field_id"

  create_table "case_step_data_fields", force: true do |t|
    t.integer "case_step_id", null: false
    t.integer "field_id",     null: false
    t.string  "value"
  end

  add_index "case_step_data_fields", ["case_step_id"], :name => "index_case_step_data_fields_on_case_step_id"

  create_table "case_step_data_images", force: true do |t|
    t.string   "image"
    t.string   "file_name"
    t.integer  "case_step_data_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_step_data_images", ["case_step_data_field_id"], :name => "index_case_step_data_images_on_case_step_data_field_id"

  create_table "case_steps", force: true do |t|
    t.integer  "case_id"
    t.integer  "step_id"
    t.integer  "step_version",         default: 1
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "trigger_ids",          default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "responsible_user_id"
    t.integer  "responsible_group_id"
  end

  add_index "case_steps", ["case_id"], :name => "index_case_steps_on_case_id"
  add_index "case_steps", ["created_by_id", "updated_by_id"], :name => "index_case_steps_on_created_by_id_and_updated_by_id"
  add_index "case_steps", ["responsible_group_id"], :name => "index_case_steps_on_responsible_group_id"
  add_index "case_steps", ["responsible_user_id"], :name => "index_case_steps_on_responsible_user_id"
  add_index "case_steps", ["step_id"], :name => "index_case_steps_on_step_id"

  create_table "cases", force: true do |t|
    t.integer  "created_by_id",                          null: false
    t.integer  "updated_by_id"
    t.integer  "responsible_user"
    t.integer  "responsible_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initial_flow_id",                        null: false
    t.integer  "flow_version",        default: 1
    t.string   "status",              default: "active"
    t.integer  "disabled_steps",      default: [],                    array: true
    t.integer  "resolution_state_id"
    t.integer  "original_case_id"
    t.string   "old_status"
  end

  add_index "cases", ["created_by_id", "updated_by_id"], :name => "index_cases_on_created_by_id_and_updated_by_id"
  add_index "cases", ["initial_flow_id", "flow_version"], :name => "index_cases_on_initial_flow_id_and_flow_version"
  add_index "cases", ["initial_flow_id"], :name => "index_cases_on_initial_flow_id"
  add_index "cases", ["original_case_id"], :name => "index_cases_on_original_case_id"
  add_index "cases", ["status"], :name => "index_cases_on_status"

  create_table "cases_log_entries", force: true do |t|
    t.integer  "user_id"
    t.string   "action",          null: false
    t.integer  "flow_id"
    t.integer  "step_id"
    t.integer  "case_id"
    t.integer  "before_user_id"
    t.integer  "after_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_version"
    t.integer  "new_flow_id"
    t.integer  "before_group_id"
    t.integer  "after_group_id"
    t.integer  "child_case_id"
  end

  add_index "cases_log_entries", ["case_id"], :name => "index_cases_log_entries_on_case_id"
  add_index "cases_log_entries", ["flow_id"], :name => "index_cases_log_entries_on_flow_id"
  add_index "cases_log_entries", ["step_id"], :name => "index_cases_log_entries_on_step_id"
  add_index "cases_log_entries", ["user_id"], :name => "index_cases_log_entries_on_user_id"

  create_table "feature_flags", force: true do |t|
    t.string   "name"
    t.integer  "status",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fields", force: true do |t|
    t.string   "title"
    t.string   "field_type"
    t.integer  "category_inventory_id"
    t.integer  "category_report_id"
    t.integer  "origin_field_id"
    t.boolean  "active",                default: true
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "multiple",              default: false
    t.string   "filter"
    t.hstore   "requirements"
    t.hstore   "values"
    t.integer  "user_id"
    t.integer  "origin_field_version"
    t.boolean  "draft",                 default: true
  end

  add_index "fields", ["active"], :name => "index_fields_on_active"
  add_index "fields", ["draft"], :name => "index_fields_on_draft"
  add_index "fields", ["field_type"], :name => "index_fields_on_field_type"
  add_index "fields", ["step_id"], :name => "index_fields_on_step_id"

  create_table "flows", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "created_by_id",                                 null: false
    t.integer  "updated_by_id"
    t.boolean  "initial",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                     default: "active"
    t.integer  "step_id"
    t.integer  "current_version"
    t.boolean  "draft",                      default: true
    t.json     "resolution_states_versions", default: {}
    t.json     "steps_versions",             default: {}
  end

  add_index "flows", ["initial"], :name => "index_flows_on_initial"
  add_index "flows", ["status", "current_version", "draft"], :name => "index_flows_on_status_and_current_version_and_draft"
  add_index "flows", ["step_id"], :name => "index_flows_on_step_id"

  create_table "group_permissions", force: true do |t|
    t.integer  "group_id"
    t.boolean  "manage_flows",                          default: false
    t.boolean  "manage_users",                          default: false
    t.boolean  "manage_inventory_categories",           default: false
    t.boolean  "manage_inventory_items",                default: false
    t.boolean  "manage_groups",                         default: false
    t.boolean  "manage_reports_categories",             default: false
    t.boolean  "manage_reports",                        default: false
    t.boolean  "manage_inventory_formulas",             default: false
    t.boolean  "manage_config",                         default: false
    t.boolean  "delete_inventory_items",                default: false
    t.boolean  "delete_reports",                        default: false
    t.boolean  "edit_inventory_items",                  default: false
    t.boolean  "edit_reports",                          default: false
    t.boolean  "view_categories",                       default: false
    t.boolean  "view_sections",                         default: false
    t.boolean  "panel_access",                          default: false
    t.integer  "groups_can_edit",                       default: [],    array: true
    t.integer  "groups_can_view",                       default: [],    array: true
    t.integer  "reports_categories_can_edit",           default: [],    array: true
    t.integer  "reports_categories_can_view",           default: [],    array: true
    t.integer  "inventory_categories_can_edit",         default: [],    array: true
    t.integer  "inventory_categories_can_view",         default: [],    array: true
    t.integer  "inventory_sections_can_view",           default: [],    array: true
    t.integer  "inventory_sections_can_edit",           default: [],    array: true
    t.integer  "inventory_fields_can_edit",             default: [],    array: true
    t.integer  "inventory_fields_can_view",             default: [],    array: true
    t.integer  "flow_can_view_all_steps",               default: [],    array: true
    t.integer  "flow_can_execute_all_steps",            default: [],    array: true
    t.integer  "can_view_step",                         default: [],    array: true
    t.integer  "can_execute_step",                      default: [],    array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "create_reports_from_panel",             default: false
    t.integer  "flow_can_delete_all_cases",             default: [],    array: true
    t.integer  "flow_can_delete_own_cases",             default: [],    array: true
    t.boolean  "users_full_access",                     default: false
    t.boolean  "groups_full_access",                    default: false
    t.boolean  "reports_full_access",                   default: false
    t.boolean  "inventories_full_access",               default: false
    t.boolean  "inventories_formulas_full_access",      default: false
    t.integer  "group_edit",                            default: [],    array: true
    t.integer  "group_read_only",                       default: [],    array: true
    t.integer  "reports_items_read_public",             default: [],    array: true
    t.integer  "reports_items_create",                  default: [],    array: true
    t.integer  "reports_items_edit",                    default: [],    array: true
    t.integer  "reports_items_delete",                  default: [],    array: true
    t.integer  "reports_categories_edit",               default: [],    array: true
    t.integer  "inventories_items_read_only",           default: [],    array: true
    t.integer  "inventories_items_create",              default: [],    array: true
    t.integer  "inventories_items_edit",                default: [],    array: true
    t.integer  "inventories_items_delete",              default: [],    array: true
    t.integer  "inventories_categories_edit",           default: [],    array: true
    t.integer  "inventories_category_manage_triggers",  default: [],    array: true
    t.integer  "reports_items_read_private",            default: [],    array: true
    t.integer  "reports_items_forward",                 default: [],    array: true
    t.integer  "reports_items_create_internal_comment", default: [],    array: true
    t.integer  "reports_items_create_comment",          default: [],    array: true
    t.integer  "reports_items_alter_status",            default: [],    array: true
  end

  add_index "group_permissions", ["can_execute_step"], :name => "index_group_permissions_on_can_execute_step"
  add_index "group_permissions", ["can_view_step"], :name => "index_group_permissions_on_can_view_step"
  add_index "group_permissions", ["flow_can_delete_all_cases"], :name => "index_group_permissions_on_flow_can_delete_all_cases"
  add_index "group_permissions", ["flow_can_delete_own_cases"], :name => "index_group_permissions_on_flow_can_delete_own_cases"
  add_index "group_permissions", ["flow_can_execute_all_steps"], :name => "index_group_permissions_on_flow_can_execute_all_steps"
  add_index "group_permissions", ["flow_can_view_all_steps"], :name => "index_group_permissions_on_flow_can_view_all_steps"
  add_index "group_permissions", ["group_id"], :name => "index_group_permissions_on_group_id"
  add_index "group_permissions", ["groups_can_edit"], :name => "index_group_permissions_on_groups_can_edit"
  add_index "group_permissions", ["groups_can_view"], :name => "index_group_permissions_on_groups_can_view"
  add_index "group_permissions", ["inventory_categories_can_edit"], :name => "index_group_permissions_on_inventory_categories_can_edit"
  add_index "group_permissions", ["inventory_categories_can_view"], :name => "index_group_permissions_on_inventory_categories_can_view"
  add_index "group_permissions", ["inventory_fields_can_edit"], :name => "index_group_permissions_on_inventory_fields_can_edit"
  add_index "group_permissions", ["inventory_fields_can_view"], :name => "index_group_permissions_on_inventory_fields_can_view"
  add_index "group_permissions", ["inventory_sections_can_edit"], :name => "index_group_permissions_on_inventory_sections_can_edit"
  add_index "group_permissions", ["inventory_sections_can_view"], :name => "index_group_permissions_on_inventory_sections_can_view"
  add_index "group_permissions", ["reports_categories_can_edit"], :name => "index_group_permissions_on_reports_categories_can_edit"
  add_index "group_permissions", ["reports_categories_can_view"], :name => "index_group_permissions_on_reports_categories_can_view"

  create_table "groups", force: true do |t|
    t.string   "name"
    t.hstore   "permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",       default: false, null: false
  end

  create_table "groups_users", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id", :unique => true
  add_index "groups_users", ["user_id"], :name => "index_groups_users_on_user_id"

  create_table "groups_users_tables", force: true do |t|
  end

  create_table "inventory_categories", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon"
    t.string   "marker"
    t.string   "color"
    t.string   "pin"
    t.string   "plot_format"
    t.boolean  "require_item_status", default: false, null: false
    t.boolean  "locked",              default: false
    t.datetime "locked_at"
    t.integer  "locker_id"
  end

  create_table "inventory_categories_reports_categories", id: false, force: true do |t|
    t.integer "reports_category_id"
    t.integer "inventory_category_id"
  end

  add_index "inventory_categories_reports_categories", ["reports_category_id", "inventory_category_id"], :name => "rep_cat_inv_cat_index"

  create_table "inventory_field_options", force: true do |t|
    t.integer  "inventory_field_id"
    t.string   "value"
    t.boolean  "disabled",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_field_options", ["inventory_field_id"], :name => "index_inventory_field_options_on_inventory_field_id"

  create_table "inventory_fields", force: true do |t|
    t.string   "title"
    t.string   "kind"
    t.string   "size"
    t.integer  "position"
    t.integer  "inventory_section_id"
    t.hstore   "options"
    t.hstore   "permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "required",             default: false, null: false
    t.integer  "maximum"
    t.integer  "minimum"
    t.string   "available_values",                                  array: true
    t.boolean  "disabled",             default: false
  end

  add_index "inventory_fields", ["inventory_section_id"], :name => "index_inventory_fields_on_inventory_section_id"

  create_table "inventory_formula_alerts", force: true do |t|
    t.integer  "inventory_formula_id"
    t.integer  "groups_alerted",       array: true
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level"
  end

  create_table "inventory_formula_conditions", force: true do |t|
    t.integer  "inventory_formula_id"
    t.integer  "inventory_field_id"
    t.string   "operator"
    t.string   "content",              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_formula_histories", force: true do |t|
    t.integer  "inventory_formula_id"
    t.integer  "inventory_item_id"
    t.integer  "inventory_formula_alert_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_formulas", force: true do |t|
    t.integer  "inventory_category_id"
    t.integer  "inventory_status_id"
    t.integer  "inventory_field_id"
    t.string   "operator"
    t.string   "content",               array: true
    t.integer  "groups_to_alert",       array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_item_data", force: true do |t|
    t.integer  "inventory_item_id"
    t.integer  "inventory_field_id"
    t.text     "content",                    array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_field_option_ids", array: true
  end

  add_index "inventory_item_data", ["inventory_field_id"], :name => "index_inventory_item_data_on_inventory_field_id"
  add_index "inventory_item_data", ["inventory_field_option_ids"], :name => "index_inventory_item_data_on_inventory_field_option_ids"
  add_index "inventory_item_data", ["inventory_item_id"], :name => "index_inventory_item_data_on_inventory_item_id"

  create_table "inventory_item_data_attachments", force: true do |t|
    t.integer "inventory_item_data_id"
    t.string  "attachment"
  end

  create_table "inventory_item_data_histories", force: true do |t|
    t.integer  "inventory_item_history_id",                  null: false
    t.integer  "inventory_item_data_id",                     null: false
    t.string   "previous_content"
    t.string   "new_content"
    t.integer  "previous_selected_options_ids", default: [], null: false, array: true
    t.integer  "new_selected_options_ids",      default: [], null: false, array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_item_data_histories", ["inventory_item_data_id"], :name => "index_item_data_histories_on_item_data_id"
  add_index "inventory_item_data_histories", ["inventory_item_history_id"], :name => "index_item_data_histories_on_item_history_id"

  create_table "inventory_item_data_images", force: true do |t|
    t.integer  "inventory_item_data_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_item_data_images", ["inventory_item_data_id"], :name => "index_inventory_item_data_images_on_inventory_item_data_id"

  create_table "inventory_item_histories", force: true do |t|
    t.integer  "inventory_item_id"
    t.integer  "user_id"
    t.string   "kind"
    t.text     "action"
    t.string   "object_type"
    t.integer  "objects_ids",       array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_item_histories", ["inventory_item_id"], :name => "index_inventory_item_histories_on_inventory_item_id"
  add_index "inventory_item_histories", ["kind"], :name => "index_inventory_item_histories_on_kind"
  add_index "inventory_item_histories", ["user_id"], :name => "index_inventory_item_histories_on_user_id"

  create_table "inventory_items", force: true do |t|
    t.integer  "inventory_category_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "position",              limit: {:srid=>0, :type=>"point"}
    t.string   "title"
    t.string   "address"
    t.integer  "inventory_status_id"
    t.boolean  "locked",                                                   default: false
    t.datetime "locked_at"
    t.integer  "locker_id"
    t.integer  "sequence",                                                 default: 0
  end

  add_index "inventory_items", ["inventory_category_id"], :name => "index_inventory_items_on_inventory_category_id"
  add_index "inventory_items", ["inventory_status_id"], :name => "index_inventory_items_on_inventory_status_id"
  add_index "inventory_items", ["user_id"], :name => "index_inventory_items_on_user_id"

  create_table "inventory_sections", force: true do |t|
    t.string   "title"
    t.integer  "inventory_category_id"
    t.hstore   "permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "required",                              null: false
    t.boolean  "location",              default: false, null: false
    t.boolean  "disabled",              default: false
  end

  add_index "inventory_sections", ["inventory_category_id"], :name => "index_inventory_sections_on_inventory_category_id"

  create_table "inventory_statuses", force: true do |t|
    t.integer  "inventory_category_id"
    t.string   "color",                 null: false
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_statuses", ["inventory_category_id"], :name => "index_inventory_statuses_on_inventory_category_id"

  create_table "reports_categories", force: true do |t|
    t.string   "title"
    t.string   "icon"
    t.string   "marker"
    t.integer  "resolution_time"
    t.integer  "user_response_time"
    t.boolean  "active",                                default: true,  null: false
    t.boolean  "allows_arbitrary_position",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
    t.integer  "parent_id"
    t.boolean  "confidential",                          default: false
    t.boolean  "private_resolution_time",               default: false
    t.boolean  "resolution_time_enabled",               default: false
    t.integer  "solver_groups_ids",                     default: [],                 array: true
    t.integer  "default_solver_group_id"
    t.boolean  "comment_required_when_forwarding",      default: false
    t.boolean  "comment_required_when_updating_status", default: false
  end

  add_index "reports_categories", ["parent_id"], :name => "index_reports_categories_on_parent_id"

  create_table "reports_comments", force: true do |t|
    t.integer  "reports_item_id"
    t.integer  "visibility",      default: 0
    t.integer  "author_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports_feedback_images", force: true do |t|
    t.integer  "reports_feedback_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports_feedback_images", ["reports_feedback_id"], :name => "index_reports_feedback_images_on_reports_feedback_id"

  create_table "reports_feedbacks", force: true do |t|
    t.integer  "reports_item_id"
    t.integer  "user_id"
    t.string   "kind",            null: false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports_feedbacks", ["reports_item_id"], :name => "index_reports_feedbacks_on_reports_item_id"
  add_index "reports_feedbacks", ["user_id"], :name => "index_reports_feedbacks_on_user_id"

  create_table "reports_images", force: true do |t|
    t.string   "image"
    t.integer  "reports_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports_images", ["reports_item_id"], :name => "index_reports_images_on_reports_item_id"

  create_table "reports_item_histories", force: true do |t|
    t.integer  "reports_item_id"
    t.integer  "user_id"
    t.string   "kind"
    t.text     "action"
    t.string   "object_type"
    t.integer  "objects_ids",     array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports_item_histories", ["kind"], :name => "index_reports_item_histories_on_kind"
  add_index "reports_item_histories", ["reports_item_id"], :name => "index_reports_item_histories_on_reports_item_id"
  add_index "reports_item_histories", ["user_id"], :name => "index_reports_item_histories_on_user_id"

  create_table "reports_item_status_histories", force: true do |t|
    t.integer  "reports_item_id"
    t.integer  "previous_status_id"
    t.integer  "new_status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports_items", force: true do |t|
    t.text     "address"
    t.text     "description"
    t.integer  "reports_status_id"
    t.integer  "reports_category_id"
    t.integer  "user_id"
    t.integer  "inventory_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "position",             limit: {:srid=>0, :type=>"point"}
    t.integer  "protocol",             limit: 8
    t.string   "reference"
    t.boolean  "confidential",                                            default: false
    t.integer  "reporter_id"
    t.boolean  "overdue",                                                 default: false
    t.integer  "comments_count",                                          default: 0
    t.uuid     "uuid"
    t.integer  "external_category_id"
    t.boolean  "is_solicitation"
    t.boolean  "is_report"
    t.integer  "assigned_group_id"
    t.integer  "assigned_user_id"
  end

  add_index "reports_items", ["inventory_item_id"], :name => "index_reports_items_on_inventory_item_id"
  add_index "reports_items", ["position"], :name => "index_reports_items_on_position", :spatial => true
  add_index "reports_items", ["protocol"], :name => "index_reports_items_on_protocol"
  add_index "reports_items", ["reports_category_id"], :name => "index_reports_items_on_reports_category_id"
  add_index "reports_items", ["reports_status_id"], :name => "index_reports_items_on_reports_status_id"
  add_index "reports_items", ["user_id"], :name => "index_reports_items_on_user_id"
  add_index "reports_items", ["uuid"], :name => "index_reports_items_on_uuid"

  create_table "reports_statuses", force: true do |t|
    t.string   "title"
    t.string   "color"
    t.boolean  "initial",             default: false, null: false
    t.boolean  "final",               default: false, null: false
    t.integer  "reports_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",              default: true
    t.boolean  "private",             default: false
  end

  add_index "reports_statuses", ["reports_category_id"], :name => "index_reports_statuses_on_reports_category_id"

  create_table "reports_statuses_reports_categories", force: true do |t|
    t.integer "reports_status_id"
    t.integer "reports_category_id"
    t.boolean "initial",             default: false
    t.boolean "final",               default: false
    t.boolean "private",             default: false
    t.boolean "active",              default: true
  end

  add_index "reports_statuses_reports_categories", ["reports_category_id"], :name => "index_reports_statuses_item_id"
  add_index "reports_statuses_reports_categories", ["reports_status_id", "reports_category_id"], :name => "index_reports_statuses_item_and_status_id"

  create_table "resolution_states", force: true do |t|
    t.integer  "flow_id"
    t.string   "title"
    t.boolean  "default",    default: false
    t.boolean  "active",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "draft",      default: true
    t.integer  "user_id"
  end

  add_index "resolution_states", ["active"], :name => "index_resolution_states_on_active"
  add_index "resolution_states", ["default"], :name => "index_resolution_states_on_default"
  add_index "resolution_states", ["draft"], :name => "index_resolution_states_on_draft"
  add_index "resolution_states", ["flow_id"], :name => "index_resolution_states_on_flow_id"

  create_table "steps", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "step_type"
    t.integer  "flow_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",               default: true
    t.integer  "child_flow_id"
    t.integer  "child_flow_version"
    t.boolean  "conduction_mode_open", default: true
    t.boolean  "draft",                default: true
    t.integer  "user_id"
    t.json     "fields_versions",      default: {}
    t.json     "triggers_versions",    default: {}
  end

  add_index "steps", ["draft"], :name => "index_steps_on_draft"
  add_index "steps", ["flow_id"], :name => "index_steps_on_flow_id"
  add_index "steps", ["step_type", "flow_id", "active"], :name => "index_steps_on_step_type_and_flow_id_and_active"

  create_table "trigger_conditions", force: true do |t|
    t.integer  "field_id"
    t.string   "condition_type",                null: false
    t.string   "values",                        null: false
    t.integer  "trigger_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",         default: true
    t.integer  "field_version",  default: 0
    t.boolean  "draft",          default: true
    t.integer  "user_id"
  end

  add_index "trigger_conditions", ["active"], :name => "index_trigger_conditions_on_active"
  add_index "trigger_conditions", ["draft"], :name => "index_trigger_conditions_on_draft"
  add_index "trigger_conditions", ["field_id"], :name => "index_trigger_conditions_on_field_id"
  add_index "trigger_conditions", ["trigger_id"], :name => "index_trigger_conditions_on_trigger_id"

  create_table "triggers", force: true do |t|
    t.string   "title",                                      null: false
    t.string   "action_type",                                null: false
    t.string   "action_values",                              null: false
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                      default: true
    t.text     "description"
    t.integer  "user_id"
    t.boolean  "draft",                       default: true
    t.json     "trigger_conditions_versions", default: {}
  end

  add_index "triggers", ["active"], :name => "index_triggers_on_active"
  add_index "triggers", ["draft"], :name => "index_triggers_on_draft"
  add_index "triggers", ["step_id"], :name => "index_triggers_on_step_id"

  create_table "users", force: true do |t|
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "reset_password_token"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "document"
    t.string   "address"
    t.string   "address_additional"
    t.string   "postal_code"
    t.string   "district"
    t.datetime "password_resetted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "device_token"
    t.string   "device_type"
    t.integer  "facebook_user_id"
    t.integer  "twitter_user_id"
    t.integer  "google_plus_user_id"
    t.boolean  "email_notifications",     default: true
    t.string   "unsubscribe_email_token"
    t.boolean  "disabled",                default: false
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
