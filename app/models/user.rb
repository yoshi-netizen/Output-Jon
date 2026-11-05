class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :recoverable, :omniauthable, omniauth_providers: %i[line]
  has_many :posts, dependent: :destroy
  
  # 新規登録時の同意を必須とする
  validates_acceptance_of :terms_agreed, acceptance: true, allow_nil: false, on: [ :create, :terms_agreement ]

  attribute :terms_agreed, :boolean, default: false

  before_save :record_terms_accepted_at, if: :terms_agreed?

  CURRENT_TERMS_UPDATED_AT = Time.utc(2026, 9, 1, 0, 0, 0)

  # 1日のAI使用制限回数（日本時間の0時にリセット）
  DAILY_AI_USAGE_LIMIT = 20

  # Devise内部の「email必須フラグ」をオーバーライド
  def email_required?
    # LINEログインではメールアドレスは不要
    if provider == "line"
      false
    else
      super
    end
  end
  
  # OAuth認証の結果から登録済みユーザーを返す
  # 未登録の場合は、規約に同意しているときだけ作成する（同意がなければ nil を返す）
  def self.from_omniauth(auth, terms_agreed:)
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user                # 登録済み → そのまま返す
    return nil unless terms_agreed     # 未登録・未同意 → 作らない
    create(                            # 未登録・同意あり → 作成する
      provider: auth.provider,
      uid: auth.uid,
      password: Devise.friendly_token[0, 20],
      terms_agreed: true
    )
  end

  # 今日あと何回AI生成できるか
  def remaining_ai_usage
    return DAILY_AI_USAGE_LIMIT unless ai_usage_date == Date.current
    [ DAILY_AI_USAGE_LIMIT - ai_usage_count, 0 ].max # 0回未満にならないようにする
  end

  # 今日まだAI生成できるか
  def can_use_ai?
    remaining_ai_usage.positive?
  end

  # AI生成に成功したときに1回数える
  def increment_ai_usage!
    today = Date.current
    with_lock do                         # 複数のタブから同時更新を防ぐためロックする
      if ai_usage_date == today
        new_count = ai_usage_count + 1   # 今日すでに使っている → 1回増やす
      else
        new_count = 1                    # 今日はまだ使っていない → 今回が1回目
      end
      update!(ai_usage_count: new_count, ai_usage_date: today)
    end
  end

  def agreed_to_current_terms?
    terms_accepted_at.present? && terms_accepted_at >= CURRENT_TERMS_UPDATED_AT
  end

  private

  def record_terms_accepted_at
    self.terms_accepted_at = Time.current
  end
end
