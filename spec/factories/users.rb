FactoryGirl.define do
  sequence(:password) { SecureRandom.hex[0..8] }

  factory :user do
    email { Faker::Internet.email }
    password
    password_confirmation { self.password }

    name { Faker::Name.name }
    phone '11912231545'
    document { Faker::CPF.numeric }
    address { Faker::Address.street_address }
    address_additional { Faker::Address.secondary_address }
    postal_code '04005000'
    district { Faker::Address.city }
    device_token { SecureRandom.hex }
    device_type 'ios'

    groups { [Group.find_by(name: 'Admins') || create(:group_for_admin, name: 'Admins')] }

    trait :disabled do
      disabled true
    end
  end

  factory :guest_user, parent: :user do
    groups { [create(:guest_group, name: 'Guest')] }
  end
end
