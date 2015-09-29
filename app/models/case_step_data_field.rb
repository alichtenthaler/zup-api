class CaseStepDataField < ActiveRecord::Base
  include EncodedImageUploadable
  include EncodedFileUploadable

  accepts_multiple_images_for :case_step_data_images
  accepts_multiple_files_for :case_step_data_attachments

  belongs_to :field
  belongs_to :case_step
  has_many :case_step_data_images
  has_many :case_step_data_attachments

  default_scope { order(:field_id) }

  validates_presence_of :field_id

  class Entity < Grape::Entity
    expose :id
    expose :field, using: Field::Entity
    expose :value
    expose :case_step_data_images, using: CaseStepDataImage::Entity
    expose :case_step_data_attachments, using: CaseStepDataAttachment::Entity
  end
end
