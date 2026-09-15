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
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
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
            expect(user.errors[:terms_agreed]).to include('must be accepted')
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
end
