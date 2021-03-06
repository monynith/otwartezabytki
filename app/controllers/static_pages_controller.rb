class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :only => :accept_terms_of_service
  before_filter :only => :accept_terms_of_service do
    if current_user.terms_of_service?
      redirect_to root_path
    end
  end

  def accept_terms_of_service
    @user = current_user
  end


end
