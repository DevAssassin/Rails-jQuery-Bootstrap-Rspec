require 'charlock_holmes'

class PeopleImport
  include Mongoid::Document
  add_indexes

  field :person_type
  field :actions, :type => Array, :default => []
  field :file
  field :columns, :type => Array, :default => []
  field :sample_values, :type => Array, :default => []
  field :failed, :type => Array, :default => []
  field :last_row_processed, :default => 0

  before_create :parse_first_two_lines

  referenced_in :account, index: true
  referenced_in :program, index: true
  referenced_in :user,    index: true

  mount_uploader :file, PeopleImportUploader, :mount_as => :import

  validates_presence_of :person_type
  validates_presence_of :file
  validates_presence_of :program, :if => Proc.new { |user| user.person_type == 'Recruit' }

  ImportablePersonTypes = %w{Recruit Player Coach Staff Alumni Parent Donor Person Other}

  def execute
    logger = Logger.new("#{Rails.root}/log/my.log")
    logger.info "[Import] Starting people import"
    ImportMailer.initiated(self).deliver
    row_number = 0
    CSV.parse(file.read, :headers => :first_row) do |row|
      row_number += 1
      if row_number <= last_row_processed
        logger.error "[Import] Row #{row_number} has already been processed, skipping."
        next
      end
      fields = {}
      address_fields = {}
      row.each_with_index do |field,index|
        action = actions[index]
        value = ActiveSupport::Multibyte::Chars.new(field[1]).tidy_bytes.to_s if field[1] || nil
        logger.info action
        logger.info value
        if person_class.import_fields.include? action
          fields[action.to_sym] = [fields[action.to_sym],value].compact.join("\n") if value.present?
        elsif Address.import_fields.include? action
          address_fields[action.to_sym] = [address_fields[action.to_sym],value].compact.join("\n") if value.present?
        end
      end
      begin
        person = person_create(fields, address_fields)
        self.update_attribute(:last_row_processed,row_number)
        logger.info "[Import] Successfully imported #{person.first_name} #{person.last_name} (row #{row_number})"
      rescue Exception => e
        message = "[Import] Failed for #{fields[:first_name]} #{fields[:last_name]} (row #{row_number}): #{e.message.presence || 'Unknown error'}"
        logger.error message
        failed << message
        self.update_attribute(:failed,failed)
      end
    end
    begin
      self.save
      logger.info "[Import] Finished people import"
    rescue Exception => e
      logger.error = "[Import] Failed: #{e.message}"
    ensure
      ImportMailer.completed(self).deliver
    end
  end

  def person_create(fields, address_fields)
    fields.merge!({:account => account, :program => program, :program_tags => "Import", :account_tags => "Import"})
    fields[:first_name] = "Unknown" if fields[:first_name].blank?
    fields[:last_name] = "Unknown" if fields[:last_name].blank?
    case person_type
    when "Coach"
      fields[:coach] = true
    when "Parent"
      fields[:parent] = true
    when "Alumni"
      fields[:alumnus] = true
    when "Donor"
      fields[:donor] = true
    end
    person_class.create!(fields) {|p| address_create address_fields, p}
  end

  def address_create(address_fields, person)
    address = person.build_address(address_fields)
    address.state = ModelUN.convert(address.state) if address.state.to_s.length == 2
    address.country = "United States of America" if ["United States", "US", "USA"].include? address.country
  end

  def person_class
    case person_type
    when "Recruit"
      program.sport_class
    when "Staff"
      Coach
    when "Player"
      RosteredPlayer
    when "Parent", "Alumni", "Donor", "Other"
      Person
    else
      Person.const_get(person_type)
    end
  end

  def parse_first_two_lines
    if self.columns.blank? || self.sample_values.blank?
      contents = File.read(file.path)
      detection = CharlockHolmes::EncodingDetector.detect(contents)
      utf8_encoded_content = CharlockHolmes::Converter.convert contents, detection[:encoding], 'UTF-8'
      File.write(file.path, utf8_encoded_content)

      csv = CSV.open(file.path)
      self.columns = csv.gets.map { |value| ActiveSupport::Multibyte::Chars.new(value).tidy_bytes.to_s if value }
      self.sample_values = csv.gets.map { |value| ActiveSupport::Multibyte::Chars.new(value).tidy_bytes.to_s if value }
      csv.close
    end
  end

end
