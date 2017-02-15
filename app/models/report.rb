class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include HotDate
  add_indexes

  field :name, :type => String
  field :start_date, :type => Date
  field :end_date, :type => Date
  field :interaction_type, :type => String
  field :interaction_scope, :type => String

  referenced_in :program, index: true
  referenced_in :account, index: true
  referenced_in :user,    index: true
  referenced_in :reported_user, :class_name => "User", index: true

  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :interaction_type

  hot_date :start_date
  hot_date :end_date

  def report_class
    @__klass ||= Interactions.const_get(interaction_type)
  end

  def records
    query = report_class.where(:interaction_time.gte => local_time_from_date(start_date))
    query = query.where(:interaction_time.lt => local_time_from_date(end_date.tomorrow)) if end_date.present?

    case
    when interaction_scope.blank?
      query = query.where_account_or_program(account || program)
    when interaction_scope == 'Account'
      query = query.account_level.where_account_or_program(account)
    when interaction_scope == 'Program'
      query = query.program_level.where_account_or_program(account)
    else
      query = query.where(:program_id => interaction_scope)
    end

    query = query.where(:user_id => reported_user.id) if reported_user

    query
  end

  def export_headers
    headers = []

    case
    when interaction_scope.blank?
      headers << "Account/Program" if account
    when interaction_scope == 'Program'
      headers << "Program"
    end

    headers += report_class.export_header
    headers
  end

  def export_fields(record)
    fields = []

    case
    when interaction_scope.blank? && account
      unless record.program
        fields << record.account.try(:name)
      else
        fields << record.program.try(:name)
      end
    when interaction_scope == 'Program'
      fields << record.program.try(:name)
    end

    fields += report_class.export_fields.map { |f| record.send(f).to_s }
    fields
  end

  def to_csv
    CSV.generate do |csv|
      csv << export_headers
      records.each do |record|
        csv << export_fields(record)
      end
    end
  end

  def interaction_scope_name
    case interaction_scope
    when 'Account'
      'Account-level only'
    when 'Program'
      'Program-level only'
    else
      if BSON::ObjectId.legal? interaction_scope
        Program.find(interaction_scope).try(:name)
      else
        'Account & Programs'
      end
    end
  end

  private
  def local_time_from_date(date)
    Time.zone.local(date.year, date.month, date.day)
  end
end
