module CaseHelper
  def run_triggers(step, kase, user)
    trigger_type        = nil
    trigger_values      = nil
    trigger_description = nil
    triggers            = step.triggers
    if triggers.present?
      triggers.active.each do |trigger|
        case_step  = kase.case_steps.find_by(step_id: step.id)
        conditions = trigger.trigger_conditions.active.map do |condition|
          compare_trigger_condition?(condition, case_step.case_step_data_fields)
        end
        unless conditions.include? false
          case_step.update!(trigger_ids: [trigger.id])
          trigger_type        = trigger.action_type
          trigger_values      = trigger.action_values
          trigger_description = trigger.description
          if trigger.action_type == 'finish_flow'
            kase.update!(status: 'finished', resolution_state_id: trigger_values.first)
            all_steps      = kase.initial_flow.list_all_steps
            step_index     = all_steps.index(case_step.step)
            if other_case_steps = kase.case_steps.where(step_id: all_steps[step_index+1..-1])
              other_case_steps.delete_all
              kase.log!('removed_case_step', user: user)
            end
            kase.log!('finished', user: user)
          elsif trigger.action_type == 'disable_steps'
            kase.update! disabled_steps: kase.disabled_steps.push(trigger_values).flatten.uniq
          elsif trigger.action_type == 'transfer_flow'
            kase.log!('transfer_flow', new_flow_id: trigger_values.first, user: user)
          end
          break
        end
      end
    end
    {type: trigger_type, value: trigger_values, description: trigger_description}
  end

  def compare_trigger_condition?(condition, data_fields)
    field          = condition.field
    original_value = data_fields.find_by(field_id: field.id).try(:value)
    value          = convert_data(field.field_type, original_value, field)
    cond_values    = condition.values.map { |v| convert_data(field.field_type, v, field) }
    case condition.condition_type
    when '=='
      cond_values.first == value
    when '!='
      cond_values.first != value
    when '>'
      cond_values.first > value
    when '<'
      cond_values.first < value
    when 'inc'
      cond_values.include? value
    else
      false
    end
  end

  def convert_data(type, value, elem=nil)
    return value if value.blank?
    data_value = value.is_a?(String) ? value.squish! : value

    case type
    when 'string', 'text'
      data_value = data_value.to_s
    when 'integer', 'year', 'month', 'day', 'hour', 'minute', 'second'
      data_value = data_value.to_i
    when 'decimal', 'meter', 'centimeter', 'kilometer'
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
      data_value = data_value.is_a?(String) ? eval(data_value) : data_value
    when 'category_inventory', 'category_report'
      data_value = data_value.is_a?(String) ? eval(data_value) : data_value
    when 'category_inventory_field'
      inventory_field = Inventory::Field.find(elem.origin_field_id)
      data_value      = convert_data(inventory_field.kind, data_value)
    when 'image', 'attachment', 'previous_field'
      #nothing to do
    end
    data_value
  end
end
