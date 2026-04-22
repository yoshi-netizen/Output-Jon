class Post < ApplicationRecord
  belongs_to :users

  validates :thinking_topic, presence: true
end
