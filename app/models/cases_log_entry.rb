class CasesLogEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :flow
  belongs_to :step
  belongs_to :case
  belongs_to :before_user,  class_name: 'User',  foreign_key: :before_user_id
  belongs_to :after_user,   class_name: 'User',  foreign_key: :after_user_id
  belongs_to :before_group, class_name: 'Group', foreign_key: :before_group_id
  belongs_to :after_group,  class_name: 'Group', foreign_key: :after_group_id
  belongs_to :child_case,   class_name: 'Case',  foreign_key: :child_case_id

  ACTION_TYPES = %w{create_case next_step update_step removed_case_step finished
                    transfer_case transfer_flow delete_case restored_case}

  validates :action, inclusion: {in: ACTION_TYPES}, presence: true
end
