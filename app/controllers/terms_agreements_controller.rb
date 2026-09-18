class TermsAgreementsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :require_terms_agreement # 同意画面自体が無限リダイレクトするため

  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.assign_attributes(terms_agreement_params)
    if @user.save(context: :terms_agreement)
      redirect_to new_post_path, success: "同意ありがとうございます。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def terms_agreement_params
    params.require(:user).permit(:terms_agreed)
  end
end
