class BusinessReport < ActiveRecord::Base
  belongs_to :user
  has_many :charts

  validates :title, presence: true
  validates :user,  presence: true

  validate :date_validity

  default_scope -> { order(id: :desc) }

  class Entity < Grape::Entity
    expose :id
    expose :user
    expose :title
    expose :summary
    expose :charts, using: Chart::Entity
    expose :begin_date
    expose :end_date
    expose :created_at
  end

  private

  def date_validity
    if (begin_date && end_date) && begin_date > end_date
      errors.add(:begin_date, I18n.t(:'errors.messages.begin_date'))
    end
  end
end
