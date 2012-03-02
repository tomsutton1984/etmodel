class @BaseChartView extends Backbone.View
  initialize_defaults: ->
    @model.bind('change', this.render)

  clear_container: ->
    @container_node().empty()

  max_value: ->
    sum_present = _.reduce @model.values_present(), (sum, v) -> return sum + (v > 0 ? v : 0)
    sum_future = _.reduce @model.values_future(), (sum, v) -> return sum + (v > 0 ? v : 0)
    target_results = _.flatten(@model.target_results())
    max_value = _.max($.merge([sum_present, sum_future], target_results))

  parsed_unit: ->
    unit = @model.get('unit')
    Metric.scale_unit(@max_value(), unit)

  # returns the power of thousand of the largest value shown in the chart
  # this is used to scale the values around the chart
  data_scale: ->
    Metric.power_of_thousand @max_value()

  container_node : ->
    $("#" + @model.get("container"))

  title_node : ->
    $("#charts_holder h3")

  update_title: ->
    @title_node().html(@model.get("name"))