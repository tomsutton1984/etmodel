module LayoutHelpers::OutputElementHelper
  def intro_charts_item(title, action, options = {})
    value, percent, scale_factor = 0, 0, 5
    options[:total] = 0
    if options[:query] and total = options[:total] and total != 0.0
      value = 0 #Current.gql.query(options[:query])
      percent = ((value / total) * 100).to_i
    end
    height = percent * scale_factor

    class_name = (params[:action] == action) ? "active " : ''
    class_name += title.downcase

    haml_tag :li, :style =>"height:#{height}px", :class => class_name do
      haml_tag :a, t("#{title}"), :href => ( options[:clickable] ? url_for(:action => action) : "#" )
      haml_tag 'div.number', "#{(value / BILLIONS).round(1)} PJ"
      haml_tag 'div.percentage', "#{percent}%"
    end
  end

  # TODO: refactor, use standard partials and keep things simple
  def charts
    return unless @output_element

    Current.setting.selected_output_element = nil
    Current.setting.displayed_output_element = @output_element.id
    haml_tag 'div#charts_wrapper' do
      haml_tag 'div#charts_holder' do
        if @output_element.block_chart?
          @blocks = @output_element.allowed_output_element_series
          haml_concat render "layouts/etm/cost_output_element"
        else
          haml_concat render "layouts/etm/output_element"
        end
      end
    end
  end

  def displayed_output_element_is_default?
    Current.setting.selected_output_element.nil?
  end
end