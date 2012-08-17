# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController

  expose(:relics) do
    tsearch.perform
  end

  expose(:relic) do
    if id = params[:relic_id] || params[:id]
      Relic.find(id).tap do |r|
        r.attributes = params[:relic] unless request.get?
      end
    else
      Relic.new(params[:relic])
    end
  end

  helper_method :need_captcha
  before_filter :authenticate_user!, :only => [:edit, :create, :update]

  def show
    if params[:section].present?
      render "relics/show/_#{params[:section]}" and return
    end
    relic.present? # raise ActiveRecord::RecordNotFound before entering template
  end

  def index
    # SearchTerm.store(params[:q1])
    gon.highlighted_tags = relics.highlighted_tags
  end

  def edit
    relic.entries.build
  end

  def update
    authorize! :update, relic

    [:photos, :documents, :links, :entries].each do |subresource|
      updated_nested_resources(subresource).each do |concrete_subresource|
        authorize! :update, concrete_subresource
      end
    end

    if params[:section] == 'photos' && relic.license_agreement != "1"
      relic.photos.where(:user_id => current_user.id).destroy_all
      flash[:notice] = "Ponieważ nie zgodziłeś się na opublikowanie dodanych zdjęć, zostały one usunięte."
      redirect_to relic_path(relic.id) and return
    end

    if relic.save
      if params[:entry_id]
        params[:entry_id] = nil
        render 'edit' and return
      else
        redirect_to relic_path(relic.id) and return
      end
    else
      flash[:error] = "Popraw proszę błędy wskazane poniżej"
      render 'edit' and return
    end
  end

  def download
    file_path = Rails.root.join('public', 'system', 'relics_history.csv')

    if File.exists?(file_path)
      @export_url = '/system/relics_history.csv'
      @export_date = File.atime(file_path)
      @export_size = (File.size(file_path) / 1024.0 / 1024.0).round(2)
    end
  end

  def new
  end

  protected
    def uniq_cache_key namespace = nil
      sliced_params = params[:q1].to_s.split.sort + params.slice(:page, :location).values
      cache_key =  (Digest::SHA1.new << sliced_params.compact.join(' ')).to_s
      if cache_key.blank?
        "blank-search-query"
      elsif namespace
        "#{namespace}-#{cache_key}"
      else
        cache_key
      end
    end

    def need_captcha
      if Rails.cache.read("need_captcha_#{request.remote_ip}")
        Rails.logger.info("Require captcha because of cache value for #{request.remote_ip}")
        return true
      end
      suggestion_count = Suggestion.roots.not_skipped.where(:ip_address => request.remote_ip).where('created_at >= ?', 1.minute.ago).count
      # puts "Suggestion count: #{suggestion_count}"
      if suggestion_count > 60
        Rails.cache.write("need_captcha_#{request.remote_ip}", 1)
        true
      else
        false
      end
    end

    def updated_nested_resources(resource_name)
      nested_ids = []

      if params[:relic] && params[:relic]["#{resource_name}_attributes"]
        params[:relic]["#{resource_name}_attributes"].each do |index, photo|
          nested_ids.push(photo["id"].to_i) if photo["id"].to_i > 0
        end
      end

      nested_ids.size ? relic.send(resource_name.to_sym).find(nested_ids) : []
    end

  def destroyed_nested_resources(resource_name)
    nested_ids = []

    if params[:relic] && params[:relic]["#{resource_name}_attributes"]
      params[:relic]["#{resource_name}_attributes"].each do |index, photo|
        nested_ids.push(photo["id"].to_i) if photo["_destroy"].to_i != 0
      end
    end

    nested_ids.size ? relic.send(resource_name.to_sym).find(nested_ids) : []
  end

end
