class Post < ApplicationRecord
  belongs_to :user

  validates :thinking_topic, presence: true
end
