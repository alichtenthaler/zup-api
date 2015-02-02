class GroupPermission < ActiveRecord::Base
  belongs_to :group

  def self.permissions_columns
    self.columns - %w(id group_id)
  end
end
