class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable
  has_many :posts, dependent: :destroy

  # 新規登録時の同意を必須とする
  validates_acceptance_of :terms_agreed, acceptance: true, allow_nil: false, on: [:create, :terms_agreement]

  attribute :terms_agreed, :boolean, default: false

  before_save :record_terms_accepted_at, if: :terms_agreed?

  CURRENT_TERMS_UPDATED_AT = Time.utc(2026, 9, 1, 0, 0, 0)

  def agreed_to_current_terms?
    terms_accepted_at.present? && terms_accepted_at >= CURRENT_TERMS_UPDATED_AT
  end

  private

  def record_terms_accepted_at
    self.terms_accepted_at = Time.current
  end
end
