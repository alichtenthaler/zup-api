class Inventory::ItemData < Inventory::Base
  belongs_to :item, class_name: "Inventory::Item", foreign_key: "inventory_item_id"
  belongs_to :field, class_name: "Inventory::Field", foreign_key: "inventory_field_id"

  has_many :images, class_name: "Inventory::ItemDataImage", foreign_key: "inventory_item_data_id"

  default_scope -> { order('inventory_item_data.id ASC') }

  # Location related fields
  scope :location, -> { joins(:field).where('inventory_fields.location' => true) }
  # Override the setter to allow
  # accepting images and string values
  def content=(content)
    if field.kind == "images"
      build_images_for(content)
    elsif !content.kind_of?(Array)
      write_attribute(:content, [content])
    else
      super
    end
  end

  def content
    if self.field && self.field.kind == "images"
      Inventory::ItemDataImage::Entity.represent(self.images)
    elsif !read_attribute(:content).nil? && (self.field && self.field.content_type != Array)
      super.first
    else
      super
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :field, using: Inventory::Field::Entity
    expose :content
  end

  private
    def build_images_for(images)
      return if images.nil?

      images.each do |image_data|
        if image_data['destroy'] && image_data['id']
          self.images.find(id: image_data['id']).destroy
        else
          begin
            temp_file = Tempfile.new([SecureRandom.hex(3), '.jpg'])
            temp_file.binmode
            temp_file.write(Base64.decode64(image_data['content']))
            temp_file.close

            self.images.build(image: temp_file)
          ensure
            temp_file.unlink
          end
        end
      end
    end
end
