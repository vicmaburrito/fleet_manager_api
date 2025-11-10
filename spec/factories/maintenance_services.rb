FactoryBot.define do
  factory :maintenance_service do
    association :vehicle
    description { Faker::Lorem.sentence }
    status { :pending }
    date { Faker::Date.between(from: 6.months.ago, to: Date.current) }
    cost_cents { Faker::Number.between(from: 5000, to: 50000) }
    priority { :low }
    completed_at { nil }

    trait :pending do
      status { :pending }
      completed_at { nil }
    end

    trait :in_progress do
      status { :in_progress }
      completed_at { nil }
    end

    trait :completed do
      status { :completed }
      completed_at { Faker::Time.between(from: date, to: Date.current) }
    end

    trait :low_priority do
      priority { :low }
    end

    trait :medium_priority do
      priority { :medium }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :recent do
      date { Date.current }
    end

    trait :old do
      date { 6.months.ago }
    end

    trait :expensive do
      cost_cents { 100000 }
    end

    trait :cheap do
      cost_cents { 5000 }
    end
  end
end
