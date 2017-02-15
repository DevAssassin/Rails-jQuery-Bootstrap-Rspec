class PersonSearch
  include Rails.application.routes.url_helpers

  attr_accessor :params, :current_scope

  def initialize(params, current_scope)
    @params = params || {}
    @current_scope = current_scope
  end

  def institution_id
    if params[:institution_id].is_a?(BSON::ObjectId)
      params[:institution_id]
    else
      BSON::ObjectId(params[:institution_id]) if BSON::ObjectId.legal?(params[:institution_id])
    end
  end

  def tournament_id
    if params[:tournament_id].is_a?(BSON::ObjectId)
      params[:tournament_id]
    else
      BSON::ObjectId(params[:tournament_id]) if BSON::ObjectId.legal?(params[:tournament_id])
    end
  end

  def grad_year
    params[:queries][:grad_year_filter] if params[:queries]
  end

  def projected_position
    params[:queries][:projected_position_filter] if params[:queries]
  end

  def location
    params[:queries][:location_filter] if params[:queries]
  end

  def city
    params[:queries][:city_filter] if params[:queries]
  end

  def scope_query
    params[:queries][:person_scope] if params[:queries]
  end

  def people_type
    params[:people]
  end

  def selected
    params[:selected].to_a.map { |id| id.is_a?(BSON::ObjectId) ? id : (BSON::ObjectId(id) if BSON::ObjectId.legal?(id)) }.compact
  end

  def search
    people = people_of_type(people_type)
    people = people_in_scope(people, scope_query) if current_scope.is_a? Account

    criteria = []

    unless institution_id.blank?
      criteria << [
        {:school_id => institution_id},
        {:college_id => institution_id},
        {:club_id => institution_id}
      ]
    end

    if tournament_id.present?
      criteria << [{ :tournament_ids => tournament_id }]
    end

    if grad_year.present?
      people = people.where(:graduation_year => grad_year.to_s)
    end

    if projected_position.present?
      people = people.where(:projected_position=> projected_position.to_s)
    end

    if location.present?
      people = people.where("address.state" => location.to_s)
    end

    if city.present?
      people = people.where("address.city" => city.to_s)
    end

    if selected.present?
      people = people.where(:_id => { '$in' => selected })
    end

    people = people.with_name

    unless params[:sorts].blank?
      params[:sorts].each do |attr, asc|
        people = people.order_by([attr, (asc == "1" ? :asc : :desc)])
      end
    end
    
    search_fields = []
    search_vals = []
    
    unless params[:queries].blank?
      unless params[:queries][:search].blank?
        name_search = /^#{Regexp.quote(params[:queries][:search].downcase)}/
        criteria << [
          { :searchable_name => name_search },
          { :sortable_name => name_search }
        ]
        
        searh_arr = params[:queries][:search].downcase.split(' ') 
        
        search_vals = searh_arr.compact
        
        searh_arr.each do |search_ele|
          fields = Person::SEARCH_ATTRIBUTES.select { |s| s.to_s.humanize.downcase.split(' ').include?(search_ele) }
          unless fields.empty?
            search_vals.delete(search_ele)
            search_fields = search_fields + fields
          end
        end
        
        search_fields = search_fields.uniq
        search_vals = /^#{Regexp.quote(search_vals.join(' ').downcase)}/i
        
        unless search_fields.empty?
          search_fields.each do |field|
            # criteria << [ { field => search_vals } ]
            
            if field == :city
              criteria.last << { "address.city" => search_vals }
            elsif field == :street
              criteria.last << { "address.street" => search_vals }
            elsif field == :state
              criteria.last << { "address.state" => search_vals }
            elsif field == :country
              criteria.last << { "address.country" => search_vals }
            else
              criteria.last << { field => search_vals }  
            end
          end
        end        
      end
      
      if params[:queries][:user_filter] == 'unassigned_only'
        people = people.unassigned
      elsif params[:queries][:user_filter].present?
        criteria << [{ :coach_ids => BSON::ObjectId(params[:queries][:user_filter]) },{ :watcher_ids => BSON::ObjectId(params[:queries][:user_filter]) }]
      end
      unless params[:queries][:board_filter].blank?
        board = RecruitBoard.find(params[:queries][:board_filter])
        criteria << [{ :_id => { '$in' => board.recruit_ids } }]
      end
      unless params[:queries][:tag_filter].blank?
        tag_filter = Person.convert_string_to_array(params[:queries][:tag_filter], ',')
        criteria << [{Person.scoped_tags_name(current_scope) => { '$all' => tag_filter } }]
      end
    end

    people = people.where({'$and' => criteria.map { |c| {'$or' => c} } }) if criteria.present?
    
    people = people.limit(params[:limit].to_i).offset(params[:offset].to_i)

    people
  end

  def each_result
    search.enum_for(:each).extend(EnumeratorExtensions)
  end

  def each_csv
    each_result.lazy_map do |p|
      converted = p.becomes(person_class)
      converted.to_csv
    end
  end

  def to_csv
    Enumerator.new do |enum|
      enum.yield(person_class.csv_header)
      each_csv.each {|c| enum.yield c}
    end
  end

  private
  def people_of_type(type)
    return [] if current_scope.nil?
    case type
    when 'recruits'
      current_scope.recruits
    when 'coaches'
      current_scope.coaches
    when 'archives'
      current_scope.archives
    when 'staff'
      current_scope.staffs
    when 'rostered_players'
      current_scope.rostered_players
    when 'others'
      current_scope.others
    when 'donors'
      current_scope.donors
    when 'alumni'
      current_scope.alumni
    when 'parents'
      current_scope.parents
    else
      current_scope.people
    end
  end

  def people_in_scope(people, scope)
    if scope == 'Account'
      people.account_level
    elsif scope == 'Program'
      people.program_level
    elsif BSON::ObjectId.legal?(scope)
      people.where(:program_id => scope)
    else
      people
    end
  end

  def current_program
    current_scope if current_scope.is_a? Program
  end

  def person_class
    Person.person_subclass(people_type, current_program)
  end
end
