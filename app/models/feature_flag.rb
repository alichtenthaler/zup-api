class FeatureFlag < ActiveRecord::Base
  validates :name, presence: true

  # We won't need this anymore when we
  # update to Rails 4.1
  def enable!
    update(status: 1) if disabled?
  end

  def disable
    update(status: 0) if enabled?
  end

  def disabled?
    status == 0
  end

  def enabled?
    status == 1
  end

  def status_name
    enabled? ? :enabled : :disabled
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :status_name
  end
end
