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
  factory :reports_item, :class => 'Reports::Item' do
    position do
      RGeo::Geographic::simple_mercator_factory.point(
        *RandomLocationPoint.location(-23.5505200, -46.6333090, 100).reverse
      )
    end
    address { Faker::Address.street_address }
    reference "Perto da padaria"
    description 'Aconteceu algo de ruim por aqui'
    association :category, factory: :reports_category_with_statuses
    association :user, factory: :user

    trait :with_feedback do
      after(:create) do |reports_item, _|
        create(:reports_feedback,
               reports_item: reports_item,
               user: reports_item.user)
      end
    end

    factory :reports_item_with_images do
      after(:create) do |reports_item, _|
        create_list(:report_image, 2, item: reports_item)
      end
    end
  end
end
