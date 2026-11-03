require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    describe '新規登録' do
      it 'メールアドレスとパスワードがあれば有効であること' do
        user = build(:user)
        expect(user).to be_valid
      end

      it 'メールアドレスが空だと無効であること' do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
      end

      it 'パスワードが空だと無効であること' do
        user = build(:user, password: nil, password_confirmation: nil)
        expect(user).not_to be_valid
      end

      it 'パスワードが5文字以下だと無効であること' do
        user = build(:user, password: "a" * 5, password_confirmation: "a" * 5)
        expect(user).not_to be_valid
      end

      it 'パスワードと確認用パスワードが一致しないと無効であること' do
        user = build(:user, password_confirmation: "different")
        expect(user).not_to be_valid
      end

      it 'メールアドレスが重複していると無効であること' do
        create(:user, email: "duplicate@example.com")
        user = build(:user, email: "duplicate@example.com")
        expect(user).not_to be_valid
      end

      it 'メールアドレスの形式が不正だと無効であること' do
        user = build(:user, email: "invalid-email")
        expect(user).not_to be_valid
      end
    end

    describe '規約同意' do
      describe 'terms_agreed' do
        context 'contextが:createのとき' do
          it 'terms_agreedがfalseだと無効であること' do
            user = build(:user, terms_agreed: false)
            expect(user).not_to be_valid(:create)
          end

          it 'terms_agreedがtrueだと有効であること' do
            user = build(:user, terms_agreed: true)
            expect(user).to be_valid(:create)
          end
        end

        context 'contextが:terms_agreementのとき' do
          it 'terms_agreedがfalseだと無効であること' do
            user = build(:user, terms_agreed: false)
            expect(user).not_to be_valid(:terms_agreement)
          end

          it 'terms_agreedがtrueだと有効であること' do
            user = build(:user, terms_agreed: true)
            expect(user).to be_valid(:terms_agreement)
          end
        end

        context 'contextが:updateのとき' do
          it 'terms_agreedがfalseでも無効にならないこと' do
            user = create(:user)
            user.terms_agreed = false
            expect(user).to be_valid(:update)
          end
        end
      end

      describe '同意日時の記録（before_saveコールバック）' do
        it 'terms_agreedがtrueで保存すると、同意日時が記録されること' do
          user = build(:user, terms_agreed: true, terms_accepted_at: nil)
          user.save
          expect(user.terms_accepted_at).to be_present
        end

        it 'terms_agreedがfalseで保存すると、同意日時は記録されないこと' do
          user = create(:user)
          user.update_column(:terms_accepted_at, nil)
          user.terms_agreed = false
          user.save
          expect(user.terms_accepted_at).to be_nil
        end
      end
    end
  end

  describe 'AI生成の利用回数' do
    it '一度も使ってない場合、残り回数が最大であること' do
      user = build(:user, ai_usage_count: 0)
      expect(user.remaining_ai_usage).to eq(User::DAILY_AI_USAGE_LIMIT)
    end

    it 'すでに何回か使っている場合、残り回数が正しく計算されること' do
      user = build(:user, ai_usage_count: 3, ai_usage_date: Date.current)
      expect(user.remaining_ai_usage).to eq(User::DAILY_AI_USAGE_LIMIT - 3)
    end

    it 'すでに最大回数使っている場合、残り回数が0であること' do
      user = build(:user, ai_usage_count: User::DAILY_AI_USAGE_LIMIT, ai_usage_date: Date.current)
      expect(user.remaining_ai_usage).to eq(0)
    end

    it '日付が変わると残り回数がリセットされること' do
      user = build(:user, ai_usage_count: User::DAILY_AI_USAGE_LIMIT, ai_usage_date: Date.yesterday)
      expect(user.remaining_ai_usage).to eq(User::DAILY_AI_USAGE_LIMIT)
    end

    it '使用するとDBの使用回数が増加すること' do
      user = create(:user, ai_usage_count: 5, ai_usage_date: Date.current)
      user.increment_ai_usage!
      expect(user.reload.ai_usage_count).to eq(6)
    end

    it '日付が変わってから使用すると、回数が1にリセットされ、最終使用日が今日になること' do
      user = create(:user, ai_usage_count: User::DAILY_AI_USAGE_LIMIT, ai_usage_date: Date.yesterday)
      user.increment_ai_usage!
      expect(user.reload.ai_usage_count).to eq(1)
      expect(user.ai_usage_date).to eq(Date.current)
    end

    it '上限の1回手前なら、使用できること' do
      user = build(:user, ai_usage_count: User::DAILY_AI_USAGE_LIMIT - 1, ai_usage_date: Date.current)
      expect(user.can_use_ai?).to be true
    end

    it '上限に達している場合、使用できないこと' do
      user = build(:user, ai_usage_count: User::DAILY_AI_USAGE_LIMIT, ai_usage_date: Date.current)
      expect(user.can_use_ai?).to be false
    end
  end
end
