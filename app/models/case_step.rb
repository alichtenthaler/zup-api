class CaseStep < ActiveRecord::Base
  belongs_to :case
  belongs_to :step
  belongs_to :trigger
  has_many   :cases_log_entries
  has_many   :case_step_data_fields
  belongs_to :created_by,        class_name: 'User',  foreign_key: :created_by_id
  belongs_to :updated_by,        class_name: 'User',  foreign_key: :updated_by_id
  belongs_to :responsible_user,  class_name: 'User',  foreign_key: :responsible_user_id
  belongs_to :responsible_group, class_name: 'Group', foreign_key: :responsible_group_id

  accepts_nested_attributes_for :case_step_data_fields

  URI_FORMAT   = /(^$)|(^(http|https|ftp|udp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
  EMAIL_FORMAT = /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/

  validate :fields_of_step

  #TODO adicionar where depois do filtro de versoes
  def my_step
    return step if step_version.blank? or step_version > step.versions.count
    step.versions[step_version-2].try(:reify)
  end

  private
  def fields_of_step
    return if self.case_step_data_fields.blank?
    field_data = convert_field_data self.case_step_data_fields
    self.step.fields.each do |field|
      data_field = field_data.select{|f| f.field_id == field.id}.try(:first)
      requirement = Hash(field.requirements)
      if data_field.present?
        value   = convert_data(field.field_type, data_field['value'], data_field)
        minimum = convert_data(field.field_type, requirement['minimum'], data_field)
        maximum = convert_data(field.field_type, requirement['maximum'], data_field)
      else
        value, minimum, maximum = nil
      end
      presence = (requirement['presence'] == 'true')

      custom_validations(field, value, minimum, maximum, presence)
    end
    @items_with_update.map(&:save!) if self.errors.blank? and @items_with_update.present?
  end

  def custom_validations(field, value, minimum, maximum, presence, field_type=nil)
    if value.blank?
      errors_add(field.title, :blank) if presence
      return
    end

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
      errors_add(field.title, :invalid) unless value =~ URI_FORMAT
    when 'email'
      errors_add(field.title, :invalid) unless value =~ EMAIL_FORMAT
    when 'image', 'attachment'
      names = value.map{ |d| d['file_name'] }
      errors_add(field.title, :invalid) unless valid_extension_by_filter?(names, field.filter)
    when 'previous_field'
      #TODO verify if is only for show field (not for update)
    when 'category_inventory'
      errors_add(field.title, :inclusion) if (value - field.category_inventory.items.select(:id).map(&:id)).present?
    when 'category_inventory_field'
      inventory_field = Inventory::Field.find(field.origin_field_id)
      value   = convert_data(inventory_field.kind, value)
      minimum = convert_data(inventory_field.kind, inventory_field.minimum)
      maximum = convert_data(inventory_field.kind, inventory_field.maximum)
      custom_validations(inventory_field, value, minimum, maximum, inventory_field.required, inventory_field.kind)
      if self.errors.blank? and @items_with_update
        @items_with_update.each do |item|
          item_field = item.data.select { |d| d.inventory_field_id == inventory_field.id }.try(:first)
          item_field.content = value
        end
      end
    when 'category_report'
      errors_add(field.title, :inclusion) if (value - field.category_report.items.select(:id).map(&:id)).present?
    end
    if value.is_a? String or value.is_a? Array
      errors_add(field.title, :greater_than, count: minimum) if minimum.present? and value.size < minimum.to_i
      errors_add(field.title, :less_than, count: maximum)    if maximum.present? and value.size > maximum.to_i
    else
      errors_add(field.title, :greater_than, count: minimum) if minimum.present? and value < minimum
      errors_add(field.title, :less_than, count: maximum)    if maximum.present? and value > maximum
    end
  end

  def valid_extension_by_filter?(value, filter)
    return true  if filter.blank?
    return false if value.blank?
    Array.new(value).each do |val|
      file_extension = val.match(/[^\.]+$/).to_s
      return false unless filter.split(',').include? file_extension
    end
    true
  end

  def convert_data(type, value, elem=nil)
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
    when 'checkbox'
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
      ## TODO return value only
    when 'category_inventory'
      @items_with_update = elem.field.category_inventory.items.where(id: eval(data_value))
      data_value = @items_with_update.map(&:id)
    when 'category_inventory_field'
      inventory_field = Inventory::Field.find(elem.field.origin_field_id)
      data_value      = convert_data(inventory_field.kind, data_value)
    when 'category_report'
      #not to do
    end
    data_value
  end

  def convert_field_data(field)
    field.is_a?(String) ? eval(field) : field
  end

  def errors_add(name, error_type, *options)
    error = "errors.messages.#{error_type}"
    errors.add(:fields, "#{name} #{I18n.t(error, *options)}")
  end

  class Entity < Grape::Entity
    def my_step(instance, options)
      options.merge!(display_type: 'basic') if Array(options[:simplify_to]).include? instance.id
      Step::Entity.represent(instance.my_step, options)
    end

    expose :id
    expose :case_id, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :step_id, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :step_version, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :my_step do |instance, options| my_step(instance, options) end
    expose :case_step_data_fields, using: CaseStepDataField::Entity, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :trigger_ids, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :responsible_user_id, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :responsible_group_id, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :created_by, using: User::Entity, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :updated_by, using: User::Entity, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :created_at, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
    expose :updated_at, unless: lambda { |instance, options| Array(options[:simplify_to]).include? instance.id }
  end
end
