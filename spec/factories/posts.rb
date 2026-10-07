FactoryBot.define do
  factory :post do
    thinking_topic    { "テストのテーマ" }
    thinking_diffusion { "考えの箇条書き" }
    thinking_core     { "【壁打ち】 モヤモヤしていることを言語化したい" }
    thinking_output   { nil }
    association :user
  end
end
