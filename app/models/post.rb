class Post < ApplicationRecord
  belongs_to :user

  validates :thinking_topic, presence: true

  # 整理の目的の種類を定義
  CORE_THINKING_TYPES = [
    '【報連相】 どう伝えればいいか整理したい',
    '【学び・感想】 記事や講演の内容を自分の血肉にしたい',
    '【会議・打合せ】 決まったことと次やることを明確にしたい',
    '【壁打ち】 モヤモヤしていることを言語化したい'
  ]

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "thinking_core", "thinking_topic"]
  end
end
