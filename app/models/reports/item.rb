class Reports::Item < Reports::Base
  include EncodedImageUploadable
  include LikeSearchable

  accepts_multiple_images_for :images

  set_rgeo_factory_for_column(:position, RGeo::Geographic.simple_mercator_factory)

  belongs_to :status, foreign_key: 'reports_status_id', class_name: 'Reports::Status'
  belongs_to :category, foreign_key: 'reports_category_id', class_name: 'Reports::Category'
  belongs_to :user, include: [:groups]
  belongs_to :inventory_item, class_name: 'Inventory::Item'
  belongs_to :reporter, class_name: 'User'

  has_many :inventory_categories, through: :category
  has_many :images, foreign_key: 'reports_item_id',
                    class_name: 'Reports::Image',
                    dependent: :destroy,
                    autosave: true
  has_many :statuses, through: :category
  has_many :status_categories, through: :category
  has_many :status_history, foreign_key: 'reports_item_id',
                            class_name: 'Reports::ItemStatusHistory',
                            dependent: :destroy,
                            autosave: true
  has_one :feedback, class_name: 'Reports::Feedback',
                     foreign_key: :reports_item_id,
                     dependent: :destroy
  has_many :comments, class_name: 'Reports::Comment',
                     foreign_key: :reports_item_id,
                     counter_cache: :comments_count,
                     dependent: :destroy

  before_save :set_initial_status
  before_validation :get_position_from_inventory_item

  after_create :generate_protocol

  validates :description, length: { maximum: 800 }

  accepts_nested_attributes_for :comments

  def inventory_item_category_id
    self.inventory_item.try(:inventory_category_id)
  end

  # Returns the last public status if the status is the private one
  def status_for_user
    if status.private_for_category?(category)
      status_history.public.last.try(:new_status)
    else
      status
    end
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
      self.fetch_image_versions(image.image).merge(original: image.url)
    end

    structure
  end

  def status_history_for_user
    status_history.public
  end

  class Entity < Grape::Entity
    expose :id
    expose :protocol
    expose :overdue

    expose :address do |obj, _|
      if obj.address
        obj.address
      elsif obj.inventory_item.present?
        obj.inventory_item.location[:address]
      end
    end

    expose :reference
    expose :confidential
    expose :comments_count

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
      expose :status_for_user, as: :status, using: Reports::Status::Entity
      expose :category, using: Reports::Category::Entity
      expose :inventory_item, using: Inventory::Item::Entity
      expose :feedback, using: Reports::Feedback::Entity
      expose :status_history_for_user, as: :status_history, using: Reports::ItemStatusHistory::Entity
      expose :comments, using: Reports::Comment::Entity
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

    private

    def protocol
      user = options[:user]
      permissions = UserAbility.new(user)

      if permissions.can?(:access, "Panel") ||
          permissions.can?(:manage, Reports::Category) ||
          permissions.can?(:edit, object) || user == object.user
        object.protocol
      end
    end

    def comments
      Reports::GetCommentsForUser.new(object, options[:user]).comments
    end
  end

  private

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
        new_status = self.category.status_categories.initial.first!.status
        Reports::UpdateItemStatus.new(self).set_status(new_status)
      end
    end
end
