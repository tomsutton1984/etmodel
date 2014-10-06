class @Setting extends Backbone.Model
  constructor: ->
    super
    @on 'change:use_fce', @on_fce_status_change

  url: -> '/settings'

  # Always use PUT requests
  isNew : -> false

  toggle_fce: (event) =>
    @set(use_fce: !! $(event.target).attr('checked'))

  on_fce_status_change: (setting, use_fce) =>
    # Old scenarios may provide "null" instead of true/false, and this causes
    # the FCE warning to toggle on.
    use_fce = false unless use_fce is true
    $('#settings_use_fce').attr('checked', use_fce)

    @save use_fce: use_fce
    App.call_api()

    # update dashboard item text for co2_reduction
    if item = dashboard.find_by_key('co2_reduction')
      item.view.update_header(
        if use_fce
          I18n.t 'constraints.greenhouse_gas.label'
        else
          I18n.t 'constraints.co2_reduction.label' )

    # update dashboard item text for local_co2_reduction
    if item = dashboard.find_by_key('local_co2_reduction')
      item.view.update_header(
        if use_fce
          I18n.t 'constraints.greenhouse_gas.label'
        else
          I18n.t 'constraints.local_co2_reduction.label' )

  toggle_peak_load_tracking: =>
    @save track_peak_load: $("#track_peak_load_settings").is(':checked')
    App.call_api()

  # Used by the bio-footprint dashboard item
  country: => @get('area_code').split('-')[0]

  # Is MO enabled?
  merit_order_enabled: ->
    try
      values = App.input_elements.user_values.settings_enable_merit_order
      values? && values.user == 1
    catch error
      # handles uninitialized user values hash.
      # TODO: use deferred object
      false

  toggle_merit_order: =>
    new_value = if @merit_order_enabled() then 0 else 1
    # if the slider is already on screen
    if slider = App.input_elements.find_by_key 'settings_enable_merit_order'
      slider.set 'user_value', new_value
    # Otherwise let's update the user_values hash and fire an API request
    else
      App.input_elements.user_values.settings_enable_merit_order.user = new_value
      App.call_api
        settings_enable_merit_order: new_value
