# -*- encoding : utf-8 -*-
class PhotosController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]
  before_filter :enable_fancybox, :only => [:show]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:photos, ancestor: :relic)
  expose(:photo)

  expose(:tree_photos, model: :photo) { relic.all_photos }
  expose(:tree_photo,  model: :photo)

  def create
    photo
    authorize! :create, photo
    photo.user = current_user
    if photo.save
      choosen_redirect_path
    else
      flash[:error] = photo.errors.first.last
      choosen_redirect_path
    end
  end

  def update
    authorize! :update, photo
    photo.save
    respond_with(relic, photo)
  end

  def destroy
    authorize! :destroy, photo
    photo.destroy
    choosen_redirect_path
  end

  private
    def choosen_redirect_path
      path = if !!params[:build]
        photos_relicbuilder_path(:id => relic.id)
      else
        edit_section_relic_path(relic.id, :photos, iframe_url_options)
      end
      redirect_to path
    end

end
