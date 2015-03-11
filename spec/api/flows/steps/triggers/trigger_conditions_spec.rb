require 'rails_helper'

describe Flows::Steps::Triggers::TriggerConditions::API do
  let(:user)       { create(:user) }
  let(:guest_user) { create(:guest_user) }
  let!(:flow)      { create(:flow, steps: [build(:step_type_form)]) }
  let(:step)       { flow.steps.first }
  let(:field)      { step.fields.first }
  let(:trigger) do
    params_to_create = {'title'=>'Trigger 1','action_type'=>'disable_steps',
                        'action_values'=>[1,2,3],'trigger_conditions_attributes'=>
                        [{'field_id'=>field.id,'condition_type'=>'==','values'=>[1]}]}
    post "/flows/#{flow.id}/steps/#{step.id}/triggers", params_to_create, auth(user)
    Trigger.last
  end
  let(:trigger_condition) { trigger.trigger_conditions.first }

  describe 'on delete' do
    context 'no authentication' do
      before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{trigger.id}/trigger_conditions/#{trigger_condition.id}" }
      it     { expect(response.status).to be_an_unauthorized }
    end

    context 'with authentication' do
      context 'and user can\'t manage triggers' do
        before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{trigger.id}/trigger_conditions/#{trigger_condition.id}", {}, auth(guest_user) }
        it     { expect(response.status).to be_a_forbidden }
      end

      context 'and user can manage triggers' do
        context 'and failure' do
          context 'because not found' do
            before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{trigger.id}/trigger_conditions/12345678", {}, auth(user) }

            it { expect(response.status).to be_a_not_found }
            it { expect(response.body).to be_an_error('Couldn\'t find TriggerCondition with id=12345678 [WHERE "trigger_conditions"."trigger_id" = $1]') }
          end
        end

        context 'successfully' do
          before { delete "/flows/#{flow.id}/steps/#{step.id}/triggers/#{trigger.id}/trigger_conditions/#{trigger_condition.id}", {}, auth(user) }

          it { expect(response.status).to be_a_success_request }
          it { expect(response.body).to be_a_success_message_with(I18n.t(:trigger_condition_deleted)) }
        end
      end
    end
  end
end
