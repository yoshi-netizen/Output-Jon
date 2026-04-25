FactoryBot.define do
  factory :post do
    thinking_topic { "テストのテーマ" }

    # Userモデルのファクトリを自動的に紐付けます
    association :user
  end
end
