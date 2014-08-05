class Reports::Status < Reports::Base
  has_and_belongs_to_many :categories,
    class_name: "Reports::Category",
    join_table: "reports_statuses_reports_categories",
    foreign_key: "reports_status_id",
    association_foreign_key: "reports_category_id"

  has_many :reports_items, class_name: 'Reports::Item', foreign_key: 'reports_status_id'

  validates :color, css_hex_color: true
  validates :title, presence: true, uniqueness: true
  validates :initial, inclusion: { in: [false, true] }
  validates :final, inclusion: { in: [false, true] }
  validates :active, inclusion: { in: [false, true] }

  before_validation :set_default_attributes

  scope :final, -> { where(final: true) }
  scope :initial, -> { where(initial: true) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :color
    expose :initial
    expose :final
    expose :active

    with_options(if: { display_type: :full }) do
      expose :created_at
      expose :updated_at
    end
  end

  private
    def set_default_attributes
      self.initial = false if initial.nil?
      self.final = false if final.nil?
      self.active = true if active.nil?
      true
    end
end
