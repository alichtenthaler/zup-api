module Flows::Steps::Fields
  class API < Grape::API
    resources ':step_id/fields' do
      desc 'Get all Fields'
      get do
        authenticate!
        validate_permission!(:view, Field)
        { fields: Field::Entity.represent(Step.find(safe_params[:step_id]).fields, only: return_fields) }
      end

      desc 'Update order of Fields'
      params { requires :ids, type: Array, desc: 'Array with steps ids in order' }
      put do
        authenticate!
        validate_permission!(:update, Field)
        Step.find(safe_params[:step_id]).fields.update_order!(safe_params[:ids], current_user)
        { message: I18n.t(:fields_order_updated) }
      end

      desc 'Create a Field'
      params do
        requires :title,                 type: String,  desc: 'Title of Field'
        requires :field_type,            type: String,  desc: 'Type of Field'
        optional :filter,                type: String,  desc: 'Filter for attachment type (ex.: *.pdf,*.txt)'
        optional :origin_field_id,       type: Integer, desc: 'If type is previous_field need to set origin_field_id'
        optional :category_inventory_id, type: Integer, desc: 'Category Inventory ID'
        optional :category_report_id,    type: Integer, desc: 'Category Report ID'
        optional :order_number,          type: Integer, desc: 'Order Number for Field'
        optional :requirements,          type: Hash,    desc: 'Requirements for Field'
        optional :values,                type: Hash,    desc: 'Values for Checkbox Field'
      end
      post do
        authenticate!
        validate_permission!(:create, Field)

        parameters = safe_params.permit(:title, :field_type, :filter, :origin_field_id, :category_inventory_id,
                                        :category_report_id, requirements: [:presence, :minimum, :maximum])
        parameters.merge!(values: safe_params[:values], user: current_user)

        field = Step.find(safe_params[:step_id]).fields.create!(parameters)
        { message: I18n.t(:field_created), field: Field::Entity.represent(field, only: return_fields) }
      end

      desc 'Update a Field'
      params do
        optional :title,                 type: String,  desc: 'Title of Field'
        optional :field_type,            type: String,  desc: 'Type of Field'
        optional :filter,                type: String,  desc: 'Filter for attachment type (ex.: *.pdf,*.txt)'
        optional :origin_field_id,       type: Integer, desc: 'If type is previous_field need to set origin_field_id'
        optional :category_inventory_id, type: Integer, desc: 'Category Inventory ID'
        optional :category_report_id,    type: Integer, desc: 'Category Report ID'
        optional :order_number,          type: Integer, desc: 'Order Number for Field'
        optional :requirements,          type: Hash,    desc: 'Requirements for Field'
        optional :values,                type: Hash,    desc: 'Values for Checkbox Field'
      end
      put ':id' do
        authenticate!
        validate_permission!(:update, Field)

        parameters = safe_params.permit(:title, :field_type, :filter, :origin_field_id, :category_inventory_id,
                                        :category_report_id, requirements: [:presence, :minimum, :maximum])
        parameters.merge!(values: safe_params[:values], user: current_user)

        Step.find(safe_params[:step_id]).fields.find(safe_params[:id]).update!(parameters)
        { message: I18n.t(:field_updated) }
      end

      desc 'Delete a Field'
      delete ':id' do
        authenticate!
        validate_permission!(:delete, Field)

        field = Step.find(safe_params[:step_id]).fields.find(safe_params[:id])
        field.user = current_user
        field.inactive!
        { message: I18n.t(:field_deleted) }
      end
    end
  end
end
