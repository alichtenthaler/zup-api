class CaseStepDataAttachment < ActiveRecord::Base
  mount_uploader :attachment, FilesUploader

  belongs_to :case_step_step_data

  def url
    attachment.url
  end

  class Entity < Grape::Entity
    expose :url
  end
end
