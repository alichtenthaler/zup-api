class Reports::Item < Reports::Base
  include EncodedImageUploadable
  include LikeSearchable

  accepts_multiple_images_for :images

  set_rgeo_factory_for_column(:position, RGeo::Geographic.simple_mercator_factory)

  belongs_to :status, foreign_key: 'reports_status_id', class_name: 'Reports::Status'
  belongs_to :category, foreign_key: 'reports_category_id', class_name: 'Reports::Category'
  belongs_to :user, include: [:groups]
  belongs_to :inventory_item, class_name: 'Inventory::Item'

  has_many :inventory_categories, through: :category
  has_many :images, foreign_key: 'reports_item_id',
                    class_name: 'Reports::Image',
                    autosave: true
  has_many :statuses, through: :category
  has_many :status_history, foreign_key: 'reports_item_id',
                            class_name: 'Reports::ItemStatusHistory',
                            autosave: true
  has_one :feedback, class_name: 'Reports::Feedback',
                     foreign_key: :reports_item_id

  before_save :set_initial_status
  before_validation :get_position_from_inventory_item

  after_create :generate_protocol
  after_create :send_email_to_user, if: :user

  validates :description, length: { maximum: 800 }

  def update_status(new_status)
    set_status_history_update(new_status)
    self.status = new_status
  end

  def update_status!(new_status)
    update_status(new_status)
    self.save!

    if self.status_history.count > 1
      UserMailer.delay.notify_report_status_update(self)
    end
  end

  def inventory_item_category_id
    self.inventory_item.try(:inventory_category_id)
  end

  # TODO: Maybe we should save this calculation
  # as a 'feedback_expirates_at' on the
  # reports_items table.
  def can_receive_feedback?
    if self.category.user_response_time.present? && self.status.final?
      final_status_datetime = self.status_history.last.created_at
      expiration_datetime = final_status_datetime + \
        self.category.user_response_time.seconds

      return expiration_datetime.to_date >= Date.today
    else
      return false
    end
  end

  def fetch_image_versions(mounted)
    res = {}

    if mounted.versions.empty?
      res = mounted.to_s
    else
      mounted.versions.each do |name, v|
        res[name] = fetch_image_versions(v)
      end
    end

    res
  end

  def images_structure
    structure = self.images.map do |image|
      self.fetch_image_versions(image.image)
    end

    structure
  end


  class Entity < Grape::Entity
    expose :id
    expose :protocol

    expose :address do |obj, _|
      obj.address || obj.inventory_item.location[:address]
    end
    expose :reference

    expose :position do |obj, _|
      if obj.inventory_item.nil?
        if obj.respond_to?(:position) && !obj.position.nil?
          position = obj.position
        end
      else
        position = obj.inventory_item.position
      end

      unless position.nil?
        { latitude: position.y, longitude: position.x }
      end
    end
    expose :description
    expose :category_icon do |obj|
      if obj.category.present?
        obj.category.icon
      end
    end
    expose :user, using: User::Entity

    # With display_type equal to full
    with_options(if: { display_type: 'full' }) do
      expose :inventory_categories, using: Inventory::Category::Entity
      expose :status, using: Reports::Status::Entity
      expose :category, using: Reports::Category::Entity
      expose :inventory_item, using: Inventory::Item::Entity
      expose :feedback, using: Reports::Feedback::Entity
      expose :status_history, using: Reports::ItemStatusHistory::Entity
    end

    # With display_type different to full
    with_options(unless: { display_type: 'full' }) do
      expose :reports_status_id, as: 'status_id'
      expose :reports_category_id, as: 'category_id'
      expose :inventory_item_id
    end

    expose :images_structure, as: :images
    expose :inventory_item_category_id
    expose :created_at
    expose :updated_at
  end

  private
    def set_status_history_update(new_status)
      if new_status.id != self.status.try(:id)
        self.status_history.build(
          previous_status: self.status,
          new_status: new_status
        )
      end
    end

    def send_email_to_user
      UserMailer.delay.notify_report_creation(self)
    end

    def generate_protocol
      if self.protocol.blank?
        generated_protocol = self.id.to_s

        if self.reports_category_id.present?
          generated_protocol << self.reports_category_id.to_s.rjust(5, '0')
        else
          generated_protocol << "00000"
        end

        (16 - generated_protocol.size).times do
          generated_protocol << rand(10).to_s
        end

        self.update(protocol: generated_protocol.to_i)
      end
    end

    def get_position_from_inventory_item
      if self.inventory_item.present? &&
          (self.new_record? || self.inventory_item_id_changed?)
        self.position = self.inventory_item.position
      end
    end

    # before_save
    def set_initial_status
      if self.status.nil?
        new_status = self.category.statuses.initial.first!
        update_status(new_status)
      end
    end
end
