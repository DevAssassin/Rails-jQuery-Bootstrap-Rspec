class DashboardController < ApplicationController
  class Settings
    def initialize(scope, controller)
      @scope = scope
      @controller = controller
    end

    def show_recruits?
      Program === @scope
    end

    def show_programs?
      Account === @scope
    end

    def show_tasks?
      true
    end

    def filter_callback_url
      case @scope
      when Account
        @controller.account_dashboard_interactions_path(@controller.current_account)
      when Program
        @controller.program_dashboard_interactions_path(@controller.current_program)
      end
    end
  end

  set_tab :dashboard
  helper_method :current_scope, :settings

  def show
    @interactions = current_scope.interactions.limit(100).order(:interaction_time.desc)
    @interactions = @interactions.where(:user_id => params[:user_filter]) unless params[:user_filter].blank?

    if settings.show_recruits?
      @recent_recruits = current_scope.recruits.limit(25).order(:touched_at.desc)
    end

    if settings.show_programs?
      @programs = current_scope.programs.order(:name.asc)
    end
    if settings.show_tasks? && current_account.compliance?
      @tasks = current_scope.tasks.sorted_by_due.incomplete
    end

    if current_account.rules_engine?
      @alerts = Interactions::Alert.where_account_or_program(current_scope).visible.limit(5)
    end

    render
  end

  def interactions
    @interactions = Interaction.find_subclass(params[:interaction_type])

    case
    when params[:interaction_scope].blank?
      @interactions = @interactions.where_account_or_program(current_scope)
    when params[:interaction_scope] == 'Account'
      @interactions = @interactions.account_level
    when params[:interaction_scope] == 'Program'
      @interactions = @interactions.program_level
    else
      @interactions = @interactions.where(:program_id => params[:interaction_scope])
    end

    @interactions = @interactions.limit(25).order(:created_at.desc)

    content = render_cell :interaction, :list, :interactions => @interactions

    render(:text => {:html => content}.to_json)
  end

  private

  def settings
    @_settings = Settings.new(current_scope, self)
    @_settings
  end

  def search_profile

  end

  def my_camps

  end

  def socials

  end

  def facebook
    #@auth = request.env["omniauth.auth"]
    @response = RestClient.get 'https://graph.facebook.com/oauth/access_token', :params => {
                   :client_id => Scoutforce::FACEBOOK_CLIENT_ID,
                   :redirect_uri => Scoutforce::FACEBOOK_REDIRECT_URI.html_safe,
                   :client_secret => Scoutforce::FACEBOOK_CLIENT_SECRET,
                   :code => params[:code].html_safe
                }
    @pair = response.body.split("&")[0].split("=")
    if (@pair[0] == "access_token")
      @access_token = @pair[1]
      @response = RestClient.get 'https://graph.facebook.com/me', :params => { :access_token => @access_token }
      #self.stream_url = JSON.parse(response.body)["link"]
      #self.active = true
    end
  end

  def twitter
    @auth = request.env
    #session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    #session[:access_secret] = request.env['omniauth.auth']['credentials']['secret']
    #redirect_to twitter_show_path
  end

  def twitter_show
    if session['access_token'] && session['access_secret']
      @user = client.user(include_entities: true)
    else
      redirect_to failure_path
    end
  end

  def error
    flash[:error] = "Error"
    redirect_to root_path
  end

end
