class Post < ApplicationRecord
  belongs_to :user

  validates :thinking_topic, presence: true

  # 整理の目的の種類を定義
  CORE_THINKING_TYPES = [
    "【報連相】 どう伝えればいいか整理したい",
    "【学び・感想】 記事や講演の内容を自分の血肉にしたい",
    "【会議・打合せ】 決まったことと次やることを明確にしたい",
    "【壁打ち】 モヤモヤしていることを言語化したい"
  ].freeze

  # 検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    [ "thinking_core", "thinking_topic" ]
  end

  # 検索可能な関連を定義
  # 関連をたどる検索は許可しない(Userモデルを検索させない)
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
