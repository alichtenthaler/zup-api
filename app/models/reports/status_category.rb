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
      initial: false, final: false
    })
  }

  private

  def set_default_attributes
    self.initial = self.status.initial if self.initial.nil?
    self.final = self.status.final if self.final.nil?
    self.active = self.status.active if self.active.nil?
    self.private = self.status.private if self.private.nil?

    true
  end
end
