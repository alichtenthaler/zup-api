require 'rails_helper'

describe Flows::Steps::Fields::API do
  let!(:user)       { create(:user) }
  let!(:guest_user) { create(:guest_user) }

  describe 'on create' do
    let!(:flow) do
       flow=create(:flow, steps: [build(:step_type_form_without_fields)])
       flow.steps.first.fields << build(:field, field_type: 'category_inventory', category_inventory_id: inventory_item.category.id, multiple: true)
       flow
    end
    let(:inventory_item) { create(:inventory_item) }
    let(:step)         { flow.steps.first }
    let(:valid_params) { {title: 'Number', field_type: 'integer'} }

    context 'no authentication' do
      before { post "/flows/#{flow.id}/steps/#{step.id}/fields", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage fields' do
        before { post "/flows/#{flow.id}/steps/#{step.id}/fields", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because validations fields' do
            let(:errors) { {'title' => [I18n.t('activerecord.errors.messages.blank')], 'field_type' => [I18n.t('activerecord.errors.messages.blank')]} }
            before { post "/flows/#{flow.id}/steps/#{step.id}/fields", {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error(errors) }
          end
        end

        context 'successfully' do
          context 'basic fields' do
            let(:field) { step.reload.fields.last }
            before { post "/flows/#{flow.id}/steps/#{step.id}/fields", valid_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:field_created)) }
            it { expect(parsed_body['field']).to be_an_entity_of(field) }
          end

          context 'with checkbox field' do
            let(:checkbox_params) do
              {title: 'Services', field_type: 'checkbox', requirements: {presence: true},
               values: {option_1: 'Option 1', option_2: 'Option 2'}}
            end
            let(:field) { step.reload.fields.last }

            before { post "/flows/#{flow.id}/steps/#{step.id}/fields", checkbox_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:field_created)) }
            it { expect(parsed_body['field']).to be_an_entity_of(field) }

            it 'should has values' do
              expect(field.values).to_not be_blank
            end
          end

          context 'with Inventory field' do
            let(:field)          { step.reload.fields.last }
            let(:inventory_params) do
              {title: 'Size of tree', field_type: 'category_inventory_field',
               origin_field_id: inventory_item.category.fields.first.id, requirements: {presence: true}}
            end

            before { post "/flows/#{flow.id}/steps/#{step.id}/fields", inventory_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:field_created)) }
            it { expect(parsed_body['field']).to be_an_entity_of(field) }
          end

          context 'with requirements' do
            let(:full_params)         { valid_params.merge(requirements: {presence:true, minimum:1, maximum:10}) }
            let(:field)               { step.reload.fields.last }
            let(:expect_requirements) { {'presence'=>'true', 'minimum'=>'1', 'maximum'=>'10'} }

            before { post "/flows/#{flow.id}/steps/#{step.id}/fields", full_params, auth(user) }

            it { expect(response.status).to be_a_requisition_created }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:field_created)) }
            it { expect(parsed_body['field']).to be_an_entity_of(field) }

            it 'should has requirements' do
              expect(field.requirements).to eql(expect_requirements)
            end

            it 'should update fields_versions on step' do
              expect(step.reload.fields_versions).to eql({field.id.to_s => nil, step.fields.first.id.to_s => nil})
            end
          end
        end
      end
    end
  end

  describe 'on update' do
    let!(:flow)        { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)         { flow.steps.first }
    let(:field)        { step.fields.first }
    let(:valid_params) { {title: 'New Title', field_type: 'date'} }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage fields' do
        before { put "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because not found' do
            before { put "/flows/#{flow.id}/steps/#{step.id}/fields/123456789", valid_params, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Field with id=123456789 [WHERE "fields"."step_id" = $1]') }
          end

          context 'because validations fields' do
            let(:errors) { {'field_type' => [I18n.t('activerecord.errors.messages.inclusion')]} }
            before { put "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", valid_params.merge(field_type:'wrong'), auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(response.body).to be_an_error(errors) }
          end
        end

        context 'successfully' do
          context 'basic fields' do
            let(:field) { step.reload.fields.first }
            before { put "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", valid_params, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:field_updated)) }
          end

          context 'with requirements' do
            let(:full_params) { valid_params.merge(requirements: {presence:true, minimum:1, maximum:10}) }
            let(:field)       { step.reload.fields.first }
            before { put "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", full_params, auth(user) }

            it { expect(response.status).to be_a_success_request }
            it { expect(response.body).to be_a_success_message_with(I18n.t(:field_updated)) }

            it 'should update fields_versions on step' do
              expect(step.reload.fields_versions).to eql({field.id.to_s => nil})
            end
          end
        end
      end
    end
  end

  describe 'on delete' do
    let!(:flow) { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)  { flow.steps.first }
    let(:field) { step.fields.first }

    context 'no authentication' do
      before { delete "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage fields' do
        before { delete "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because not found' do
            before { delete "/flows/#{flow.id}/steps/#{step.id}/fields/123456789", {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Field with id=123456789 [WHERE "fields"."step_id" = $1]') }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/steps/#{step.id}/fields/#{field.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:field_deleted)) }
        end
      end
    end
  end

  describe 'on list' do
    let!(:flow) { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)  { flow.steps.first }
    let(:field) { step.fields.first }

    context 'no authentication' do
      before { get "/flows/#{flow.id}/steps/#{step.id}/fields" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage fields' do
        before { get "/flows/#{flow.id}/steps/#{step.id}/fields", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage steps' do
        context 'with no fields' do
          before { get "/flows/#{flow.id}/steps/#{step.id}/fields", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['fields']).to include_an_entity_of(field) }
        end

        context 'with two fields' do
          let!(:other_field) { create(:field, step: step) }
          before { get "/flows/#{flow.id}/steps/#{step.id}/fields", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(parsed_body['fields']).to include_an_entity_of(field) }
          it { expect(parsed_body['fields']).to include_an_entity_of(other_field) }
        end
      end
    end
  end

  describe 'on sort' do
    let!(:flow)        { create(:flow, steps: [build(:step_type_form, fields: [build(:field), build(:field)])]) }
    let(:step)         { flow.steps.first }
    let(:field)        { step.fields.first }
    let(:other_field)  { step.fields.second }
    let(:valid_params) { {ids: [other_field.id, field.id]} }

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps/#{step.id}/fields", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage fields' do
        before { put "/flows/#{flow.id}/steps/#{step.id}/fields", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage steps' do
        context 'and failure' do
          context 'because not found' do
            before { put "/flows/#{flow.id}/steps/#{step.id}/fields", {ids:[123456789]}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find Field with id=123456789 [WHERE "fields"."step_id" = $1]') }
          end
        end

        context 'successfully' do
          before { put "/flows/#{flow.id}/steps/#{step.id}/fields", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:fields_order_updated)) }

          it 'should has fields_versions on step' do
            expect(step.reload.fields_versions).to eql({field.id.to_s => nil, other_field.id.to_s => nil})
          end
        end
      end
    end
  end
end
