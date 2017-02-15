class PeopleController < ApplicationController
  respond_to :html, :json

  skip_before_filter :authenticate_user!, :set_user_state,
    :only => [:online_new, :online_create, :invited_recruit, :invite_update, :search]

  set_tab :contacts

  # GET /recruits
  # GET /recruits.xml
  def index
    params[:type] ||= 'all'
    session[:type] = params[:type]

    @people = current_scope.people

    respond_with(@people) do |format|
      format.html do
        case params[:type]
        when 'recruits'
          @cell ||= render_cell :recruit, :list, {}
          @sidebar ||= render_cell :recruit, :list_sidebar
          set_tab :recruits, :subnav
        when 'coaches'
          @cell = render_cell :coach, :list, type: 'coaches'
          @sidebar ||= render_cell :coach, :list_sidebar
          set_tab :coaches, :subnav
        when 'staff'
          @cell = render_cell :coach, :list, :type => 'staff'
          @sidebar ||= render_cell :coach, :list_sidebar
          set_tab :staff, :subnav
        when 'rostered_players'
          @cell = render_cell :rostered_player, :list, {}
          @sidebar ||= render_cell :rostered_player, :list_sidebar
          set_tab :roster, :subnav
        when 'others'
          @cell = render_cell :person, :list, :type => 'others'
          @sidebar ||= render_cell :person, :list_sidebar
          set_tab :other, :subnav
        when 'donors'
          @cell = render_cell :donor, :list, {}
          @sidebar ||= render_cell :person, :list_sidebar
          set_tab :donor, :subnav
        when 'alumni'
          @cell = render_cell :alumnus, :list, {}
          @sidebar ||= render_cell :person, :list_sidebar
          set_tab :alumni, :subnav
        when 'parents'
          @cell = render_cell :parent, :list, {}
          @sidebar ||= render_cell :person, :list_sidebar
          set_tab :parents, :subnav
        when 'archives'
          @cell = render_cell :archive, :list, :type => 'archives'
          @sidebar ||= render_cell :archive, :list_sidebar
        when 'all'
          @cell = render_cell :person, :list, {}
          @sidebar ||= render_cell :person, :list_sidebar
          set_tab :all, :subnav
        end

        # load javascript variable to initialize dynatable with
        # last number of records selected
        @perPageCell = render_cell :person, :perpage

        render 'index'
      end

      format.xml  { render :xml => @people }
      format.csv  {
        self.response_body = PersonSearch.new(params, current_scope).to_csv
        headers['Content-Disposition'] = "attachment; filename=people.csv"
      }
      format.json { render :json => @people.json_list_for_api }
    end
  end

  # TODO: Merge these methods?

  def print_all
    search = PersonSearch.new(params, current_scope)
    respond_with @people = search.search.order_by([[:sortable_name,:asc]]), :layout => 'print'
  end

  def print_recruits
    search = PersonSearch.new(params, current_scope)
    respond_with @people = search.search.order_by([[:sortable_name,:asc]]), :layout => 'print'
  end

  def search
    people = PersonSearch.new({:queries => {:search => params[:term]}, :limit => 10}, current_scope)
    if people
      json = people.search.map do |i|
        {
          :id => i.id,
          :label => i.name.titleize,
          :value => i.name,
          :city => i.address.try(:city).try(:titleize),
          :state => i.address.try(:state),
          :url => person_path(i)
        }
      end
      respond_with(json)
    else
      respond_with([])
    end
  end

  def dynatable
    # store limit in a session var that we can use to make the records per page "sticky"
    session[:perPage] = params[:limit]
    search = PersonSearch.new(params, current_scope)

    @people = search.search
    queried_record_count = @people.count
    @people = @people.to_a

    @people.each do |person|
      person[:program_name] = person.program.try(:name)
      person[:profile_link] = person_path(person)
      person[:state] = person.state
      person[:city] = person.city
      person[:city_and_state] = person.is_a?(Recruit) ? person.city_and_state : ""
      person[:children_profiles] = person.children.map { |c| c.name }.join(', ')
    end

    json = {
      :queried_record_count => queried_record_count,
      :records => @people
    }

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  # GET /recruits/1
  # GET /recruits/1.xml
  def show
    @person = current_scope.people.find_even_if_deleted(params[:id])
    if @person
      @person.touch

      person_page = @person.destroyed? ? "show_deleted" : "show"

      respond_with(@person) do |format|
        format.html { render person_page }
        format.json { render :json => @person, :except => :authentication_token, :rules_engine => current_account.rules_engine? }
      end
    else
      render :text => "The person you tried to access is not part of your current program or account.", :status => 404, :layout => true
    end
  end

  def print
    respond_with @person = current_scope.people.find_even_if_deleted(params[:id]), :layout => 'print'
  end

  def new
    if current_program || params[:type] != 'recruit'
      @person = create_person(params[:type])
      @person.account = current_account
      @person.program = current_program
      @person.coach = true if params[:type] == 'coach'
      @person.coach = false if params[:type] == 'staff'

      if params[:institution]
        inst = Institution.find(params[:institution])

        case inst
        when School
          @person.school = inst
        when College
          @person.college = inst
        when Club
          @person.club = inst
        end
      end

      respond_with(@person, :action => 'new')
    else
      render "new_recruit_programs"
    end
  end

  # GET /recruits/1/edit
  def edit
    @person = current_scope.people.find(params[:id])
  end

  # POST /recruits
  # POST /recruits.xml
  def create
    @person = create_person(params[:type], params[:person])

    @person.program ||= current_program
    @person.account ||= current_account

    respond_to do |format|
      if @person.save
        #TODO figure out why recruit has to be saved before this can happen
        @person.assign_board_ids(params[:person][:recruit_board_ids]) if params[:person][:recruit_board_ids]
        @person.add_creation_interaction(:user => current_user)
        format.html { redirect_to(person_path(@person), :notice => "#{@person.type} was successfully created.") }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recruits/1
  # PUT /recruits/1.xml
  def update
    @person = current_scope.people.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        @person.assign_board_ids(params[:person][:recruit_board_ids]) if params[:person][:recruit_board_ids]
        format.html { redirect_to(person_path(@person), :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
        format.js { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recruits/1
  # DELETE /recruits/1.xml
  def destroy
    @person = current_scope.people.find(params[:id])
    @person.add_deletion_interaction(:user => current_user)
    @person.delete

    respond_to do |format|
      format.html { redirect_to people_path, :notice => "Recruit was successfully deleted." }
      format.xml  { head :ok }
    end
  end

  def mass_new
  end

  def mass_update
    #TODO shouldn't have to do this, but associations don't work right in mongoid
    people = (params[:people] || []).map { |rid| current_scope.people.find(rid) }
    coaches = (params[:coach_ids] || []).map { |cid| current_scope.users.find(cid) }

    Person.mass_add_tags(current_scope,people,params[:tags]) if params[:tags]

    if !coaches.empty?
      people.each do |person|
        person.add_watchers(coaches)
        person.save
      end
    end

    respond_to do |format|
      format.html { redirect_to(typed_people_path(session[:type])) }
      format.js { render :nothing => true }
    end
  end

  def update_boards
    boards = (params[:board_ids] || [])
    person = current_program.people.find(params[:id])

    person.assign_board_ids(boards)

    redirect_to person_path(person)
  end

  def restore
    #TODO shouldn't have to do this, but find(params[:id]) doesnt work
    person = Person.deleted.where(:_id => params[:id]).first
    person.restore
    person.add_restoration_interaction(:user => current_user)

    respond_to do |format|
      format.html { redirect_to person_path(person), :notice => "Recruit was successfully restored." }
    end
  end

  def mass_delete
    people = (params[:people] || []).map { |rid| current_scope.people.find(rid) }
    people.each do |person|
      person.add_deletion_interaction(:user => current_user)
      person.delete
    end
    render :nothing=>true
  end

  def mass_archive
    people = (params[:people] || []).map { |rid| current_scope.people.find(rid) }
    people.each do |person|
      person._type = "Archive"
      person.save
      #person.delete
    end
    render :nothing=>true
  end

  def add_to_board
    people = (params[:people] || []).map { |rid| current_scope.people.find(rid) }
    board = current_program.recruit_boards.find(params[:board_id])
    people.each do |person|
      board.push_recruit(person)
    end
    board.save
    render nothing: true
  end

  def online_new
    @program = Program.find(params[:program_id])
    @type = params[:type]
    case @type
    when 'Alumnus'
      @person = Person.new(:program => @program, :alumnus => true)
    else
      @person = @program.sport_class.new(:program => @program)
    end
    render :layout => "online_form"
  end

  def online_create
    @program = Program.find(params[:program_id])
    if params[:person][:alumnus]
      @person = Person.new(params[:person])
      @person.created_by_alumnus = true
    else
      @person = @program.sport_class.new(params[:person])
      @person.created_by_recruit = true
    end
    @person.program = @program

    respond_to do |format|
      if @person.save
        send_to_sfa
        @person.assign_board_ids(params[:person][:recruit_board_ids]) if params[:person][:recruit_board_ids]
        @person.add_creation_interaction(:creation_type => "Online Form")
        @person.mailer.confirmation_notification(@person).deliver if @person.email.present?
        format.html { render "online_confirmation", :layout => "online_form" }
      else
        format.html { render "online_new", :layout => "online_form" }
      end
    end
  end

  def invited_recruit
    @person = Person.where(:authentication_token => params[:auth_token]).first
    if @person.present?
      @program = @person.program
      render 'online_new', :layout => "online_form"
    else
      render 'expired_auth_token', :layout => "basic"
    end
  end

  def invite_update
    @person = Person.where(:authentication_token => params[:auth_token]).first
    # TODO: Refactor this to an updated! method or something. We shouldn't care what the person type is here.
    if @person.alumnus?
      @person.updated_by_alumnus = true if @person.alumnus?
    elsif @person.is_a?(Recruit)
      @person.updated_by_recruit = true
    elsif @person.is_a?(RosteredPlayer)
      @person.updated_by_rostered_player = true
    else
      @person.updated_by_person = true
    end
    @program = @person.program
    if @person.update_attributes(params[:person])
      send_to_sfa
      @person.mailer.confirmation_notification(@person).deliver if @person.email.present?
      render "online_confirmation", :layout => "online_form"
    else
      render 'online_new', :layout => "online_form"
    end
  end

  def token_complete
    scope = params[:people_program].present? ? current_scope.programs.find(params[:people_program]) : current_scope
    people = scope.people.token_search(params[:q])
    respond_to do |format|
      format.json{ render :json => people }
    end
  end

  def alumnus?
    return alumnus == true
  end

  def parent?
    return parent == true
  end

  def donor
    return donor == true
  end

  private
    def send_to_sfa
      if Rails.env.production? and @person.respond_to?(:api) and @person.api? and @person.account and @person.account.free?
        require 'net/http'
        data = @person.nonblank_visible_attributes.merge(
          {
            sport_name: @person.sport_name,
            athletic_attributes: @person.nonblank_athletic_attributes,
            school_name: @person.school_name,
            program_name: @person.program_name
          }
        )
        http = Net::HTTP.new('www.scoutforceathlete.com', 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new('https://www.scoutforceathlete.com/util/api.php', {'Content-Type' =>'application/json'})
        request.body = data.to_json
        http.request(request)
      end
    end

    def create_person(kind, *args)
      klass = Person.person_subclass(kind, current_program)
      if klass == Coach
        #TODO this seems messy:
        new_args = args.dup
        opts = new_args.pop || {}
        opts.reverse_merge!(:coach => true)
        new_args.push(opts)

        Coach.new(*new_args)
      elsif klass == Archive
        #TODO this seems messy:
        new_args = args.dup
        opts = new_args.pop || {}
        opts.reverse_merge!(:archive => true)
        new_args.push(opts)

        Archive.new(*new_args)
      else
        klass.new(*args)
      end
    end
end
