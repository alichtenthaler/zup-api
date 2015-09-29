FactoryGirl.define do
  factory :business_report do
    association :user
    title { 'Relatório' }
    summary { 'Este é um exemplo de descrição' }
    begin_date { Date.new(2015, 6, 1) }
    end_date { Date.new(2015, 6, 30) }

    trait :without_dates do
      begin_date nil
      end_date nil
    end
  end
end
