FactoryGirl.define do
  sequence(:password) { SecureRandom.hex[0..8] }

  factory :user do
    email { FFaker::Internet.email }
    password
    password_confirmation { password }

    name { FFaker::Name.name }
    phone '11912231545'
    commercial_phone '11912231545'
    skype { FFaker::Internet.user_name }
    document { Faker::CPF.numeric }
    birthdate { Date.new(1990, 10, 10) }
    address { FFaker::Address.street_address }
    address_additional { FFaker::Address.secondary_address }
    postal_code '04005000'
    district { FFaker::Address.city }

    institution { FFaker::Company.name }
    position { FFaker::Company.position }

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
