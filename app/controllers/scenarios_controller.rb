class ScenariosController < ApplicationController
  before_filter :ensure_valid_browser
  before_filter :find_scenario, :only => [:show, :load]
  before_filter :require_user, :only => [:index, :new, :merge]
  before_filter :load_interface,
                :store_last_etm_page,
                :load_constraints,
                :prevent_browser_cache, :only => :play

  # Raised when trying to save a scenario, but the user does not have a
  # scenario in progress. See quintel/etengine#542.
  class NoScenarioIdError < RuntimeError
    def initialize(controller)
      "Cannot save ETM scenario with settings: #{ Current.setting.inspect }"
    end
  end

  rescue_from NoScenarioIdError do |ex|
    render :cannot_save_without_id, status: :bad_request
    notify_airbrake(ex)
  end

  def index
    @student_ids = current_user.students.pluck(:id)
    items = if current_user.admin?
      SavedScenario.all
    elsif current_user.students.present?
      user_ids =  @student_ids << current_user.id
      SavedScenario.includes(:user).where(user_id: user_ids)
    else
      current_user.saved_scenarios
    end
    @saved_scenarios = items.order('created_at DESC').page(params[:page]).per(50)
    SavedScenario.batch_load(@saved_scenarios)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    if @scenario.nil?
      redirect_to root_path, :notice => "Scenario not found" and return
    end
    if @scenario.description
      localized = @scenario.description_for_locale(I18n.locale)
      text = localized.present? ? localized : @scenario.description
      renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      @description = renderer.render(text).html_safe
    end
    if @scenario.created_at && @scenario.days_old > 31
      if SavedScenario.where('user_id = ? AND scenario_id = ?', current_user, @scenario).empty?
        @warning = t('scenario.preset_warning')
      else
        @warning = t('scenario.warning')
      end
    end
  end

  def new
    if Current.setting.api_session_id.blank?
      raise NoScenarioIdError.new(self)
    end

    @saved_scenario = SavedScenario.new
    @saved_scenario.api_session_id = Current.setting.api_session_id
  end

  def reset
    Current.setting.reset_scenario
    redirect_to_back
  end

  # Saves a scenario. This implies two db records: a saved_scenario in the ETM
  # and a proper scenario in the ETE. The ETM just stores the user_id and
  # scenario_id.
  #
  # POST /scenarios/
  #
  # Set the protected flag to true. The scenario_id parameter is critical: it
  # tells ETE to create a *copy* of the current scenario. Check in the engine
  # the Scenario#scenario_id= method to see what's going on.
  def create
    scenario_id = params[:saved_scenario].delete(:api_session_id)

    if scenario_id.blank?
      raise NoScenarioIdError.new(self)
    end

    attrs = { scenario: params[:saved_scenario].merge(
      :protected => true,
      :source => 'ETM',
      :scenario_id => scenario_id
    ) }

    begin
      @scenario = Api::Scenario.create(scenario: attrs)
      @saved_scenario = current_user.saved_scenarios.new

      @saved_scenario.scenario_id = @scenario.id
      # Setting a fake title because the object validates its presence - the
      # engine scenarios table actually saves it
      @saved_scenario.title = '_'
      @saved_scenario.save!

      redirect_to scenarios_path
    end
  end

  # Loads a scenario from a id.
  #
  # GET  /scenarios/:id/load
  # POST /scenarios/:id/load
  #
  def load
    if @scenario.nil?
      redirect_to play_path, :notice => "Scenario not found" and return
    end

    session[:dashboard] = nil

    scenario_attrs = { scenario_id: @scenario.id }

    Current.setting = Setting.load_from_scenario(@scenario)

    if request.post? && params[:scaling_attribute]
      scaling_attrs = Api::Scenario.scaling_from_params(params)

      scenario_attrs.merge!(scale: scaling_attrs)
      Current.setting.scaling = scaling_attrs
    end

    new_scenario = Api::Scenario.create(scenario: { scenario: scenario_attrs })
    Current.setting.api_session_id = new_scenario.id

    redirect_to play_path
  end

  # GET /scenario/grid_investment_needed
  def grid_investment_needed
    render :layout => false
  end

  # This is the main scenario action
  #
  def play
    @selected_slide_key = @interface.current_slide.short_name
    respond_to do |format|
      format.html {render :layout => 'etm'}
      format.js
    end
  end

  def compare
    scenario_ids = params[:scenario_ids] || []
    @scenarios = scenario_ids.map{|id| Api::Scenario.find id, params: {detailed: true}}
    if @scenarios.empty?
      flash[:error] = "Please select one or more scenarios"
      redirect_to scenarios_path and return
    end
    @default_values = @scenarios.first.all_inputs
    @average_values = {}
    @average_values_using_defaults = {}
  end

  def merge
    inputs = params[:inputs_def]
    @inputs = YAML.load inputs
    end_year = params[:end_year].to_i
    end_year = 2050 unless end_year.between?(2010, 2050)
    @scenario = Api::Scenario.create(
      :scenario => { :scenario => {
        :source => 'ETM',
        :user_values => @inputs,
        :title => 'Average Scenario',
        :description => 'Generated by the compare page',
        :area_code => params[:area_code] || 'nl',
        :end_year => end_year
      }}
    )
  end

  private

    # Finds the scenario from id
    def find_scenario
      @scenario = Api::Scenario.find(params[:id], :params => {:detailed => true})
    rescue ActiveResource::ResourceNotFound
      nil
    end

    def load_interface
      tab = params[:tab] || 'demand'
      @interface = Interface.new(tab, params[:sidebar], params[:slide])

      # The JS app will take care of fetching a scenario id, in the meanwhile we
      # use this variable to show all the items in the top menu
      @active_scenario = true
    end

    def store_last_etm_page
      tab_key     = @interface.current_tab.key rescue nil
      sidebar_key = @interface.current_sidebar_item.key rescue nil
      slide_key   = @interface.current_slide.short_name rescue nil
      Current.setting.last_etm_page = play_url(tab_key, sidebar_key, slide_key)
    end

    def load_constraints
      dash = session[:dashboard]

      @constraints = if dash and dash.any?
        Constraint.for_dashboard(dash)
      else
        Constraint.default.ordered
      end
    end

    def prevent_browser_cache
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
end
