FactoryBot.define do
  factory :vehicle do
    sequence(:vin) { |n| "1HGBH41JXMN10#{n.to_s.rjust(4, '0')}" }
    sequence(:plate) { |n| "ABC#{n.to_s.rjust(4, '0')}" }
    brand { "Toyota" }
    model { "Camry" }
    year { 2020 }
    status { "active" }

    trait :inactive do
      status { "inactive" }
    end

    trait :in_maintenance do
      status { "in_maintenance" }
    end

    trait :old do
      year { 1995 }
    end

    trait :recent do
      year { 2024 }
    end
  end
end
