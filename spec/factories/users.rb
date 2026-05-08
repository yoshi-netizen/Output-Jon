FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" } # test1@..., test2@... と被らない値を作る
    password { "password" }
    password_confirmation { "password" }
  end
end
