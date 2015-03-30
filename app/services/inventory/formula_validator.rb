class Inventory::FormulaValidator
  OPERATIONS = {
    'equal_to' => lambda do |content, condition_content|
      content == condition_content
    end,
    'greater_than' => lambda do |content, condition_content|
      content > condition_content.to_i
    end,
    'lesser_than' => lambda do |content, condition_content|
      content < condition_content.to_i
    end,
    'different' => lambda do |content, condition_content|
      content != condition_content
    end,
    'between' => lambda do |content, condition_content|
      condition_content.include?(content)
    end,
    'includes' => lambda do |content, condition_content|
      if content.is_a?(String)
        content.downcase[condition_content.downcase]
      elsif content.is_a?(Array)
        (condition_content & content).any?
      end
    end
  }

  attr_reader :item, :formula

  def initialize(item, formula)
    @item = item
    @formula = formula
  end

  def valid?
    formula.conditions.each do |condition|
      return false unless condition_satisfied?(condition)
    end

    true
  end

  private

  def condition_satisfied?(condition)
    operator = condition.operator
    field = condition.field
    content = item.represented_data.send(field.title)

    if field.use_options? && !content.is_a?(Array)
      content = [content]
    end

    OPERATIONS[operator].call(content, condition.content)
  end
end
