class CaseStep < ActiveRecord::Base
  belongs_to :case
  belongs_to :step
  belongs_to :trigger
  has_many :case_step_data_fields
  belongs_to :created_by,        class_name: 'User',  foreign_key: :created_by_id
  belongs_to :updated_by,        class_name: 'User',  foreign_key: :updated_by_id
  belongs_to :responsible_user,  class_name: 'User',  foreign_key: :responsible_user_id
  belongs_to :responsible_group, class_name: 'Group', foreign_key: :responsible_group_id

  accepts_nested_attributes_for :case_step_data_fields

  URI_FORMAT   = /(^$)|(^(http|https|ftp|udp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
  EMAIL_FORMAT = /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/

  validates_uniqueness_of :step_id, scope: :case_id
  validate :fields_of_step, if: -> { executed? }

  def my_step
    Version.reify(step_version)
  end

  def executed?
    case_step_data_fields.present?
  end

  private

  def fields_of_step
    field_data = convert_field_data(case_step_data_fields)

    my_step.my_fields.each do |field|
      data_field  = field_data.select{ |f| f.field_id == field.id }.try(:first)
      requirement = Hash(field.requirements)

      if data_field.present?
        value   = convert_data(field.field_type, data_field['value'],    data_field)
        minimum = convert_data(field.field_type, requirement['minimum'], data_field)
        maximum = convert_data(field.field_type, requirement['maximum'], data_field)
      else
        value, minimum, maximum = nil
      end

      presence = requirement['presence'] == 'true'
      custom_validations(field, value, minimum, maximum, presence)
    end

    @items_with_update.map(&:save!) if errors.blank? && @items_with_update.present?
  end

  def custom_validations(field, value, minimum, maximum, presence, field_type = nil)
    return presence && errors_add(field.title, :blank) if value.blank?

    field_type = field_type || field.try(:field_type)
    errors_add(field.title, :invalid) if field_type.blank?

    case field_type
    when 'angle'
      errors_add(field.title, :less_than,    count: 360)  if value > 360
      errors_add(field.title, :greater_than, count: -360) if value < -360
    when 'cpf'
      errors_add(field.title, :invalid) unless Cpf.new(value).valido?
    when 'cnpj'
      errors_add(field.title, :invalid) unless Cnpj.new(value).valido?
    when 'url'
      errors_add(field.title, :invalid) if value !~ URI_FORMAT
    when 'email'
      errors_add(field.title, :invalid) if value !~ EMAIL_FORMAT
    when 'image', 'attachment'
      names = value.map{ |d| d['file_name'] }
      errors_add(field.title, :invalid) unless valid_extension_by_filter?(names, field.filter)
    when 'previous_field'
      #nothing to do
    when 'radio'
      errors_add(field.title, :invalid) if (Array(value) - field.values).present?
    when 'checkbox', 'select'
      errors_add(field.title, :inclusion) if (Array(value) - field.values).present?
    when 'inventory_item'
      errors_add(field.title, :inclusion) if (Array(value) - Inventory::Item.where(inventory_category_id: field.category_inventory_id).pluck(:id)).present?
    when 'inventory_field'
      inventory_field = Inventory::Field.find(field.origin_field_id)

      value   = convert_data(inventory_field.kind, value)
      minimum = convert_data(inventory_field.kind, inventory_field.minimum)
      maximum = convert_data(inventory_field.kind, inventory_field.maximum)

      custom_validations(inventory_field, value, minimum, maximum, inventory_field.required, inventory_field.kind)
      if errors.blank? && @items_with_update
        @items_with_update.each do |item|
          item_field = item.data.select { |d| d.inventory_field_id == inventory_field.id }.try(:first)
          item_field.content = value
        end
      end
    when 'report_item'
      errors_add(field.title, :inclusion) if (Array(value) - Reports::Item.where(reports_category_id: field.category_report_id).pluck(:id)).present?
    end
    if value.is_a?(String) || value.is_a?(Array)
      errors_add(field.title, :greater_than, count: minimum) if minimum.present? && value.size < minimum.to_i
      errors_add(field.title, :less_than,    count: maximum) if maximum.present? && value.size > maximum.to_i
    else
      errors_add(field.title, :greater_than, count: minimum) if minimum.present? && value < minimum
      errors_add(field.title, :less_than,    count: maximum) if maximum.present? && value > maximum
    end
  end

  def valid_extension_by_filter?(value, filter)
    return false if value.blank?
    if filter.present?
      Array.new(value).each do |val|
        file_extension = val.match(/[^\.]+$/).to_s
        return false unless filter.split(',').include? file_extension
      end
    end
    true
  end

  def convert_data(type, value, elem = nil)
    return value if value.blank?
    data_value = value.is_a?(String) ? value.squish! : value

    case type
    when 'string', 'text'
      data_value = data_value.to_s
    when 'integer', 'year', 'month', 'day', 'hour', 'minute', 'second', 'years', 'months', 'days', 'hours', 'minutes', 'seconds'
      data_value = data_value.to_i
    when 'decimal', 'meter', 'centimeter', 'kilometer', 'decimals', 'meters', 'centimeters', 'kilometers'
      data_value = data_value.to_f
    when 'angle'
      data_value = data_value.to_f
    when 'date'
      data_value = data_value.to_date
    when 'time'
      data_value = data_value.to_time
    when 'date_time'
      data_value = data_value.to_datetime
    when 'email'
      data_value = data_value.downcase
    when 'checkbox', 'select'
      data_value = convert_field_data(data_value)
    when 'image'
      data_value = convert_field_data(data_value)
      elem.value = ''
      elem.update_case_step_data_images data_value
    when 'attachment'
      data_value = convert_field_data(data_value)
      elem.value = ''
      elem.update_case_step_data_attachments data_value
    when 'previous_field'
      #nothing to do
    when 'inventory_item'
      @items_with_update = Inventory::Item.where(inventory_category_id: elem.field.category_inventory).where(id: convert_field_data(data_value))
      data_value = @items_with_update.pluck(:id)
    when 'inventory_field'
      inventory_field = Inventory::Field.find(elem.field.origin_field_id)
      data_value      = convert_data(inventory_field.kind, data_value)
    when 'report_item'
      #nothing to do
    end
    data_value
  end

  def convert_field_data(field)
    return field unless field.is_a? String
    field =~ /^\[.*\]$/ || field =~ /^\{.*\}$/ ? eval(field) : field
  end

  def errors_add(name, error_type, *options)
    error = "errors.messages.#{error_type}"
    errors.add(:fields, "#{name} #{I18n.t(error, *options)}")
  end

  class Entity < Grape::Entity
    def my_step(instance, options)
      options.merge!(display_type: 'basic') if simplify_to? instance.id, options
      Step::Entity.represent(instance.my_step, options)
    end

    def simplify_to?(case_step_id, options = {})
      Array(options[:simplify_to]).include? case_step_id
    end

    def change_options_to_return_fields(key, options = {})
      return options if options[:only].blank?
      fields = options[:only].select { |field| field.is_a?(Hash) && field[key].present? }
      fields.present? && options.merge!(only: fields.first[key])
      options
    end

    expose :id
    expose :step_id
    expose :step_version
    expose :my_step do |instance, options|
      my_step(instance, change_options_to_return_fields(:my_step, options))
    end
    expose :trigger_ids
    expose :responsible_user_id
    expose :responsible_group_id
    expose :executed?, as: :executed
    expose :updated_at
    expose :created_at
    expose :case_step_data_fields, using: CaseStepDataField::Entity,
           unless: ->(instance, options) { simplify_to? instance.id, options }
    expose :created_by, using: User::Entity,
           unless: ->(instance, options) { simplify_to? instance.id, options }
    expose :updated_by, using: User::Entity,
           unless: ->(instance, options) { simplify_to? instance.id, options }
  end
end
