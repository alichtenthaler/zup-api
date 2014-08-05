class Inventory::RenderCategoryFormData
  attr_reader :category

  def initialize(category)
    @category = category
  end

  def render
    { 'sections' => Inventory::Section::Entity.represent(category.sections) }
  end
end
