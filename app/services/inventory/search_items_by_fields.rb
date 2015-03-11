module Inventory
  class SearchItemsByFields
    attr_reader :scope, :fields

    def initialize(scope = Inventory::Item, fields)
      @scope = scope
      @fields = fields
    end

    def scope_with_filters
      scope.distinct.joins(:data).joins(join_statement)
           .where(build_fields_statement)
    end

    private

    def join_statement
      <<-SQL
        LEFT JOIN inventory_field_options
        ON inventory_field_options.id = ANY(inventory_item_data.inventory_field_option_ids)
      SQL
    end

    def build_fields_statement
      statement = ""

      fields.each do |field_id, filters|
        # Filters could be a hash like this:
        # filters = {
        #   lesser_than: 30,
        #   greater_than: 40,
        #   equal_to: 40,
        #   like: "old",
        #   different: "different than this",
        #   includes: ["test", "this", "tomorrow"],
        #   excludes: ["test", "this", "tomorrow"]
        # }
        filters.each do |operation, content|
          operation = operation.to_s

          statement += " AND " unless statement.empty?

          field_id = ActiveRecord::Base.sanitize(field_id.to_i)

          case operation
          when "lesser_than"
            content = ActiveRecord::Base.sanitize(content)
            statement += build_condition_for_float(field_id, "< CAST(#{content} AS float)")
          when "greater_than"
            content = ActiveRecord::Base.sanitize(content)
            statement += build_condition_for_float(field_id, "> CAST(#{content} AS float)")
          when "equal_to"
            content = ActiveRecord::Base.sanitize(content)
            statement += build_condition(field_id, "= #{content}")
          when "like"
            content = ActiveRecord::Base.sanitize("%#{content}%")
            statement += build_condition(field_id, "LIKE #{content}")
          when "different"
            content = ActiveRecord::Base.sanitize(content)
            statement += build_condition(field_id, "!= #{content}")
          when "includes"
            content = content.inject([]) { |s, (k, v)| s << v }

            content = "{#{content.join(",")}}"
            content = ActiveRecord::Base.sanitize(content)

            statement += build_condition_for_array(field_id, content)
          when "excludes"
            content = content.inject([]) { |s, (k, v)| s << v }

            content = "{#{content.join(",")}}"
            content = ActiveRecord::Base.sanitize(content)

            statement += build_condition_for_array(field_id, content, 'NOT')
          end
        end
      end

      statement
    end

    def build_condition(field_id, content_statement)
      <<-SQL
        (
          inventory_item_data.inventory_field_id = #{field_id} AND
            (
              (
                inventory_item_data.inventory_field_option_ids IS NOT NULL AND
                  inventory_field_options.value #{content_statement}
              ) OR inventory_item_data.content[1] #{content_statement}
            )
        )
      SQL
    end

    def build_condition_for_float(field_id, content_statement)
      <<-SQL
        (
          inventory_item_data.inventory_field_id = #{field_id} AND
            (
              (
                inventory_item_data.inventory_field_option_ids IS NOT NULL AND
                  CAST(inventory_field_options.value AS float) #{content_statement}
              ) OR CAST(inventory_item_data.content[1] AS float) #{content_statement}
            )
        )
      SQL
    end

    def build_condition_for_array(field_id, content_statement, option_operator = '')
      <<-SQL
        (
          inventory_item_data.inventory_field_id = #{field_id} AND
            (
              (
                inventory_item_data.inventory_field_option_ids IS NOT NULL AND #{option_operator}
                  ARRAY(
                    (
                      SELECT value
                      FROM inventory_field_options
                      WHERE inventory_field_options.id = ANY(inventory_item_data.inventory_field_option_ids)
                    )
                  )::text[] @> #{content_statement}::text[]
              ) OR #{option_operator} inventory_item_data.content @> #{content_statement}::text[]
            )
        )
      SQL
    end
  end
end
