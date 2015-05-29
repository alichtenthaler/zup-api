class Reports::Item < Reports::Base
  include EncodedImageUploadable
  include LikeSearchable
  include BoundaryValidation

  accepts_multiple_images_for :images

  set_rgeo_factory_for_column(:position, RGeo::Geographic.simple_mercator_factory)

  belongs_to :status, foreign_key: 'reports_status_id', class_name: 'Reports::Status'
  belongs_to :category, foreign_key: 'reports_category_id', class_name: 'Reports::Category'
  belongs_to :user
  belongs_to :inventory_item, class_name: 'Inventory::Item'
  belongs_to :reporter, class_name: 'User'
  belongs_to :assigned_group, class_name: 'Group'
  belongs_to :assigned_user, class_name: 'User'

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
                     dependent: :destroy

  before_save :set_initial_status
  before_validation :get_position_from_inventory_item, :set_uuid, :clear_postal_code

  validates :description, length: { maximum: 800 }
  validates :reference, length: { maximum: 255 }, allow_nil: true
  validates :postal_code, format: { with: /\A[0-9]+\z/ }, allow_nil: true

  validate_in_boundary :position

  accepts_nested_attributes_for :comments

  def inventory_item_category_id
    inventory_item.try(:inventory_category_id)
  end

  # Returns the last public status if the status is the private one
  def status_for_user
    if status.private_for_category?(category)
      st = status_history.all_public.last.try(:new_status)
    else
      st = status
    end

    category.status_categories.find_by(reports_status_id: st.id)
  end

  # TODO: Maybe we should save this calculation
  # as a 'feedback_expirates_at' on the
  # reports_items table.
  def can_receive_feedback?
    if category.user_response_time.present? && status.for_category(category).final?
      final_status_datetime = status_history.last.created_at
      expiration_datetime = final_status_datetime + \
        category.user_response_time.seconds

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
    images.map do |image|
      fetch_image_versions(image.image).merge(original: image.url)
    end
  end

  def status_history_for_user
    status_history.all_public
  end

  class Entity < Grape::Entity
    expose :id
    expose :protocol
    expose :overdue
    expose :assigned_user, using: User::Entity
    expose :assigned_group, using: Group::Entity

    expose :address do |obj, _|
      if obj.address
        obj.address
      elsif obj.inventory_item.present?
        obj.inventory_item.location[:address]
      end
    end
    expose :number
    expose :reference
    expose :district
    expose :postal_code
    expose :city
    expose :state
    expose :country

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
    expose :reporter, using: User::Entity

    # With display_type equal to full
    with_options(if: { display_type: 'full' }) do
      expose :inventory_categories, using: Inventory::Category::Entity
      expose :status_for_user, as: :status, using: Reports::StatusCategory::Entity
      expose :category, using: Reports::Category::Entity
      expose :inventory_item, using: Inventory::Item::Entity
      expose :feedback, using: Reports::Feedback::Entity
      expose :status_history_for_user, as: :status_history, using: Reports::ItemStatusHistory::Entity
      expose :comments, using: Reports::Comment::Entity
    end

    # With display_type different to full
    with_options(unless: { display_type: 'full' }) do
      expose :inventory_item_id
    end

    expose :reports_status_id, as: :status_id
    expose :reports_category_id, as: :category_id

    expose :images_structure, as: :images
    expose :inventory_item_category_id
    expose :created_at
    expose :updated_at

    private

    def protocol
      user = options[:user]
      permissions = UserAbility.for_user(user)

      if permissions.can?(:view_private, object) ||
          permissions.can?(:edit, object) || user.try(:id) == object.user_id
        object.protocol
      end
    end

    def comments
      Reports::GetCommentsForUser.new(object, options[:user]).comments
    end
  end

  private

  def get_position_from_inventory_item
    if inventory_item.present? &&
        (self.new_record? || self.inventory_item_id_changed?)
      self.position = inventory_item.position
    end
  end

  # before_save
  def set_initial_status
    if status.nil?
      new_status = category.status_categories.initial.first!.status
      Reports::UpdateItemStatus.new(self).set_status(new_status)
    end
  end

  # Set uuid
  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.nil?
  end

  def clear_postal_code
    self.postal_code = postal_code.gsub(/[^0-9]*/, '') if postal_code
  end
end
