class Reports::StatusCategory < Reports::Base
  # I added this because the id primary key field
  # was added later.
  self.primary_key = 'id'
  self.table_name = 'reports_statuses_reports_categories'

  belongs_to :category, class_name: 'Reports::Category',
                        foreign_key: 'reports_category_id'
  belongs_to :status, class_name: 'Reports::Status',
                      foreign_key: 'reports_status_id'

  before_validation :set_default_attributes

  validates :initial, inclusion: { in: [false, true] }
  validates :final, inclusion: { in: [false, true] }
  validates :active, inclusion: { in: [false, true] }
  validates :private, inclusion: { in: [false, true] }
  validates :status, uniqueness: { scope: [:reports_category_id] }

  scope :final, -> { where(final: true) }
  scope :initial, -> { where(initial: true) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  scope :public, -> { where(private: false) }
  scope :private, -> { where(private: true) }

  scope :with_status, -> (status) { find_by(reports_status_id: status.id) }

  scope :in_progress, -> {
    where(table_name => {
      final: false
    })
  }

  class Entity < Grape::Entity
    delegate :id, :title, :color, to: :status, allow_nil: true

    expose :id
    expose :private
    expose :title
    expose :color
    expose :initial
    expose :final
    expose :active

    def status
      object.status
    end
  end

  private

  def set_default_attributes
    self.initial = status.initial if initial.nil?
    self.final = status.final if final.nil?
    self.active = status.active if active.nil?
    self.private = status.private if private.nil?

    true
  end
end
