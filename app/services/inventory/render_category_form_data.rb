class Inventory::RenderCategoryFormData
  attr_reader :category, :user

  def initialize(category, user)
    @category = category
    @user = user
  end

  def render
    {
      sections: Inventory::Section::Entity.represent(category.sections, user: user)
    }
  end
end
