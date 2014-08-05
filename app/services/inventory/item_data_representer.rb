module Inventory
  class ItemDataRepresenter
    include ActiveModel::Validations

    attr_reader :item

    def self.factory(item)
      instance_class = self.dup

      fields = item.category.fields
      fields.each do |field|
        instance_class.send(:attr_accessor, field.title)

        inject_validations(field, instance_class)
      end

      instance_class.class_eval do
        def self.model_name
          Inventory::ItemData.model_name
        end
      end

      instance_class.new(item, fields)
    end

    def initialize(item, fields)
      @_fields_cache = {}
      @item = item

      fields.each do |field|
        @_fields_cache[field.id] = field
      end

      # Get data from item.data and
      # populate the accessors
      populate_data
    end

    def attributes=(new_attributes)
      new_attributes.each do |field_id, content|
        field_id = field_id.to_i
        field = @_fields_cache[field_id]

        if field
          set_attribute_content(field, content)
        else
          raise "Inventory field with id #{field_id} doesn't exists!"
        end
      end
    end

    def inject_to_data!
      if valid?
        current_data = item.data

        @_fields_cache.each do |_, field|
          new_content = send("#{field.title}")

          item_data = current_data.select { |i| i.field == field }.first

          if item_data
            item_data.content = new_content
          else
            item.data.build(field: field, content: new_content)
          end
        end

        true
      else
        false
      end
    end

    private

    def populate_data
      if item.data.any?
        item.data.each do |item_data|
          set_attribute_content(item_data.field, item_data.content)
        end
      end
    end

    def convert_content_type(field, content)
      convertors = {
        Fixnum => proc do |content|
          content.to_i
        end,
        Float => proc do |content|
          content.to_f
        end
      }

      convertor = convertors[field.content_type]

      if convertor
        convertor.call(content)
      else
        content
      end
    end

    def set_attribute_content(field, content)
      converted_content = convert_content_type(field, content)
      send("#{field.title}=", converted_content)
    end

    # Inject validations on the duplicated class
    def self.inject_validations(field, instance_class)
      attribute = field.title
      validations = {}

      if field.required?
        validations[:presence] = true
      end

      if field.maximum
        if [Fixnum, Float].include?(field.content_type)
          validations[:numericality] = {
            less_than_or_equal_to: field.maximum
          }
        else
          validations[:length] = {
            maximum: field.maximum
          }
        end
      end

      if field.minimum
        if [Fixnum, Float].include?(field.content_type)
          validations[:numericality] ||= {}
          validations[:numericality].merge!({
            greater_than_or_equal_to: field.minimum
          })
        else
          validations[:length] ||= {}
          validations[:length].merge!({
            minimum: field.minimum
          })
        end
      end

      if validations.any?
        instance_class.send(:validates, field.title, validations)
      end
    end
  end
end
