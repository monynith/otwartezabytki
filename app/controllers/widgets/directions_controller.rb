# -*- encoding : utf-8 -*-

class Widgets::DirectionsController < WidgetsController
  layout :resolve_widget_layout, :only => [:show, :configure]

  expose(:widget_directions, model: Widget::Direction)
  expose(:widget_direction,  model: Widget::Direction)
  expose(:widget) { widget_directions.find(params[:id]) }
  expose(:widget_params) { widget.widget_params }
  expose(:categories) { widget.widget_params.try(:[], 'categories') || [] }

  expose(:widget_search) do
    params[:search] ||= { :location => 'country:pl' }
    Search.new(params[:search].merge(:widget => "1"))
  end

  expose(:relics) do
    widget_search.load = true
    widget_search.perform
  end

  def show
    widget_search
    relics
  end

  def create
    widget_direction.user_id ||= current_user.try :id
    if widget_direction.save
      redirect_to edit_widgets_direction_path(widget_direction)
    else
      redirect_to widgets_path :error => t('notices.widget_error')
    end
  end

  def edit
    authorize! :edit, widget_direction if widget_direction.user_id
  end

  def update
    authorize! :update, widget_direction if widget_direction.user_id or params[:save] or params[:save_and_print]
    widget_direction.user_id ||= current_user.try :id
    if widget_direction.has_valid_waypoints?
      if widget_direction.save
        respond_to do |format|
          format.json { head :ok }
          format.html do
            if params[:save_and_print]
              redirect_to print_widgets_direction_path(widget_direction)
            else
              redirect_to edit_widgets_direction_path(widget_direction), :notice => (t('widget.direction.save') if current_user)
            end
          end
        end
      else
        flash[:error] = t('notices.widget_error_and_correct') if current_user
        render :edit
      end
    else
      flash[:error] = t('widget.direction.no_route') if current_user
      redirect_to edit_widgets_direction_path(widget_direction)
    end
  end

  def print
    render :print, :layout => 'widgets/print'
  end

  def preview
  end

  def configure
  end

  def destroy
    authorize! :destroy, widget_direction
    widget_direction.destroy
    redirect_to user_my_routes_path(current_user.id), :notice => t('notices.route_has_been_removed')
  end

end
