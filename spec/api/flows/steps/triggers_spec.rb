require 'rails_helper'

describe Flows::Steps::Triggers::API do
  let(:user)       { create(:user) }
  let(:guest_user) { create(:guest_user) }

  describe 'on create' do
    let!(:flow)        { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)         { flow.steps.first }
    let(:field)        { step.fields.first }
    let(:valid_params) do
      {
        'title'              => 'Trigger 1',
        'action_type'        => 'disable_steps',
        'action_values'      => [1, 2, 3],
        'trigger_conditions_attributes' => [
          { 'field_id' => field.id, 'condition_type' => '==', 'values' => [1] }
        ]
      }
    end

    context 'no authentication' do
      before { post "/flows/#{flow.id}/steps/#{step.id}/triggers", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage triggers' do
        before { post "/flows/#{flow.id}/steps/#{step.id}/triggers", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage triggers' do
        context 'and failure' do
          context 'because validations fields' do
            let(:errors) do
              { 'title'                         => [I18n.t('activerecord.errors.messages.blank')],
               'trigger_conditions_attributes' => [I18n.t('activerecord.errors.messages.blank')],
               'action_type'                   => [I18n.t('activerecord.errors.messages.blank')],
               'action_values'                 => [I18n.t('activerecord.errors.messages.blank')]
              }
            end

            before { post "/flows/#{flow.id}/steps/#{step.id}/triggers", {}, auth(user) }

            it { expect(response.status).to be_a_bad_request }
            it { expect(parsed_body).to be_an_error(errors) }
          end
        end

        context 'successfully' do
          let(:trigger) { step.reload.triggers.first }

          before { post "/flows/#{flow.id}/steps/#{step.id}/triggers", valid_params, auth(user) }

          it { expect(response.status).to be_a_requisition_created }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:trigger_created)) }
          it { expect(parsed_body['trigger']).to be_an_entity_of(trigger) }

          it 'should has update triggers_versions on Step' do
            expect(step.reload.triggers_versions).to eql(trigger.id.to_s => nil)
          end
        end
      end
    end
  end

  describe 'on update' do
    let!(:flow)        { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)         { flow.steps.first }
    let(:field)        { step.fields.first }
    let(:valid_params) do
      {
        'title'         => 'New Trigger 1',
        'action_type'   => 'disable_steps',
        'action_values' => [3],
        'trigger_conditions_attributes' => [
          { 'field_id' => field.id, 'condition_type' => '>', 'values' => [1] },
          { 'field_id' => field.id, 'condition_type' => '<', 'values' => [10] }
        ]
      }
    end

    before do
      params_to_create = { 'title' => 'Trigger 1', 'action_type' => 'disable_steps',
                          'action_values' => [1, 2, 3], 'trigger_conditions_attributes' =>                           [{ 'field_id' => field.id, 'condition_type' => '==', 'values' => [1] }] }
      post "/flows/#{flow.id}/steps/#{step.id}/triggers", params_to_create, auth(user)
      @trigger = Trigger.last
    end

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps/#{step.id}/triggers/#{@trigger.id}", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage triggers' do
        before { put "/flows/#{flow.id}/steps/#{step.id}/triggers/#{@trigger.id}", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage triggers' do
        context 'and failure' do
          context 'because not found' do
            before { put "/flows/#{flow.id}/steps/#{step.id}/triggers/12345678", valid_params, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(parsed_body).to be_an_error('Couldn\'t find Trigger with \'id\'=12345678 [WHERE "triggers"."step_id" = $1]') }
          end
        end

        context 'successfully' do
          let(:trigger) { step.reload.triggers.first }

          before { put "/flows/#{flow.id}/steps/#{step.id}/triggers/#{@trigger.id}", valid_params, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:trigger_updated)) }

          it 'should has update triggers_versions on Step' do
            expect(trigger.step.reload.triggers_versions).to eql(trigger.id.to_s => nil)
          end
        end
      end
    end
  end

  describe 'on delete' do
    let!(:flow) { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)  { flow.steps.first }
    let(:field) { step.fields.first }

    before do
      params_to_create = { 'title' => 'Trigger 1', 'action_type' => 'disable_steps',
                          'action_values' => [1, 2, 3], 'trigger_conditions_attributes' =>                           [{ 'field_id' => field.id, 'condition_type' => '==', 'values' => [1] }] }
      post "/flows/#{flow.id}/steps/#{step.id}/triggers", params_to_create, auth(user)
      @trigger = Trigger.last
    end

    context 'no authentication' do
      before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{@trigger.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage triggers' do
        before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{@trigger.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage triggers' do
        context 'and failure' do
          context 'because not found' do
            before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/12345678", {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(parsed_body).to be_an_error('Couldn\'t find Trigger with \'id\'=12345678 [WHERE "triggers"."step_id" = $1]') }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{@trigger.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:trigger_deleted)) }
        end
      end
    end
  end

  describe 'on list' do
    let!(:flow) { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)  { flow.steps.first }
    let(:field) { step.fields.first }

    before do
      3.times do |n|
        params_to_create = { 'title' => "Trigger #{n}", 'action_type' => 'disable_steps',
                            'action_values' => [n], 'trigger_conditions_attributes' =>                             [{ 'field_id' => field.id, 'condition_type' => '==', 'values' => [1] }] }
        post "/flows/#{flow.id}/steps/#{step.id}/triggers", params_to_create, auth(user)
      end
      triggers  = Trigger.all
      @trigger1 = triggers.first
      @trigger2 = triggers.second
      @trigger3 = triggers.third
    end

    context 'no authentication' do
      before { get "/flows/#{flow.id}/steps/#{step.id}/triggers" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage triggers' do
        before { get "/flows/#{flow.id}/steps/#{step.id}/triggers", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage triggers' do
        before { get "/flows/#{flow.id}/steps/#{step.id}/triggers", {}, auth(user) }

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['triggers']).to include_an_entity_of(@trigger1) }
        it { expect(parsed_body['triggers']).to include_an_entity_of(@trigger2) }
        it { expect(parsed_body['triggers']).to include_an_entity_of(@trigger3) }
      end
    end
  end

  describe 'on sort' do
    let!(:flow)        { create(:flow, steps: [build(:step_type_form)]) }
    let(:step)         { flow.steps.first }
    let(:field)        { step.fields.first }
    let(:valid_params) { { ids: [@trigger2.id, @trigger3.id, @trigger1.id] } }

    before do
      3.times do |n|
        params_to_create = { 'title' => "Trigger #{n}", 'action_type' => 'disable_steps',
                            'action_values' => [n], 'trigger_conditions_attributes' =>                             [{ 'field_id' => field.id, 'condition_type' => '==', 'values' => [1] }] }
        post "/flows/#{flow.id}/steps/#{step.id}/triggers", params_to_create, auth(user)
      end
      triggers  = Trigger.all
      @trigger1 = triggers.first
      @trigger2 = triggers.second
      @trigger3 = triggers.third
    end

    context 'no authentication' do
      before { put "/flows/#{flow.id}/steps/#{step.id}/triggers", valid_params }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage triggers' do
        before { put "/flows/#{flow.id}/steps/#{step.id}/triggers", valid_params, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage triggers' do
        before { put "/flows/#{flow.id}/steps/#{step.id}/triggers", valid_params, auth(user) }

        it { expect(response.status).to be_a_success_request }
        it { expect(response.body).to be_a_success_message_with(I18n.t(:trigger_order_updated)) }

        it 'should has triggers_versions on Step' do
          expect(step.reload.triggers_versions).to eql(@trigger2.id.to_s => nil,
                                                        @trigger3.id.to_s => nil,
                                                        @trigger1.id.to_s => nil)
        end
      end
    end
  end
end
