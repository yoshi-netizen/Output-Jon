class Post < ApplicationRecord
  belongs_to :user

  validates :thinking_topic, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "thinking_core", "thinking_topic"]
  end
end
