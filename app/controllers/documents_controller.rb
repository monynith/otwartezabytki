# -*- encoding : utf-8 -*-
class DocumentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:documents) { relic.documents }
  expose(:document)

  expose(:tree_documents) { relic.all_documents }
  expose(:tree_document)

  def create
    authorize! :create, document
    document.user = current_user

    unless document.save
      flash[:error] = document.errors.first.last
    end

    redirect_to edit_section_relic_path(relic.id, :documents, iframe_url_options)
  end

  def update
    authorize! :update, document
    document.save
    respond_with(relic, document)
  end

  def destroy
    authorize! :destroy, document
    document.destroy
    redirect_to edit_section_relic_path(relic.id, :documents)
  end

end
