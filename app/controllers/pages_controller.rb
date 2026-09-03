class PagesController < ApplicationController
  skip_before_action :require_terms_agreement
  
  def terms; end

  def privacy_policy; end
end
