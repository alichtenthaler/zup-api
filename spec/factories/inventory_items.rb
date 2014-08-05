# Read about factories at https://github.com/thoughtbot/factory_girl

# obtained from here:
# http://stackoverflow.com/questions/9917159/how-to-create-random-geo-points-within-a-distance-d-from-another-geo-point/15627922#15627922
class RandomLocationPoint
  def self.location(lat, lng, max_dist_meters)
    max_radius = Math.sqrt((max_dist_meters ** 2) / 2.0)

    lat_offset = rand(max_radius) / 1000.0
    lng_offset = rand(max_radius) / 1000.0

    lat += [1,-1].sample * lat_offset
    lng += [1,-1].sample * lng_offset
    lat = [[-90, lat].max, 90].min
    lng = [[-180, lng].max, 180].min

    [lat, lng]
  end
end

FactoryGirl.define do
  factory :inventory_item, :class => 'Inventory::Item' do
    association :category, factory: :inventory_category_with_sections
    association :user, factory: :user

    before(:create) do |item, evaluator|
      item.category.fields.each do |field|
        item_data = item.data.build(field: field, content: generate(:name))

        if field.location
          latitude, longitude = RandomLocationPoint.location(-23.5505200, -46.6333090, 100)

          if field.title == "longitude"
            item_data.content = longitude
          elsif field.title == "latitude"
            item_data.content = latitude
          end
        end
      end
    end

    trait :with_status do
      association :status, factory: :inventory_status
    end
  end
end
