class MassInteraction < BasicActiveModel

  attr_accessor :original, :user
  attr_writer :interactions

  validate :has_people
  validate :interaction_valid

  def initialize(attributes = {})
    super(attributes)
  end

  def interactions
    @interactions || []
  end

  def person_ids_string
    person_ids.join(', ')
  end

  def person_ids_string=(string)
    self.person_ids = string.split(/,\s?/)
  end

  def person_ids
    @person_ids || []
  end

  def person_ids=(array)
    @person_ids = array.map { |id| id.is_a?(String) ? (BSON::ObjectId.from_string(id) if BSON::ObjectId.legal? id) : id } if array.is_a?(Array)
  end

  def people
    Person.find(person_ids)
  end

  def people=(people)
    self.person_ids = people.map(&:id)
  end

  def method_missing(method, *arguments, &block)
    if original.respond_to? method
      original.send(method)
    else
      super
    end
  end

  def respond_to?(method, include_private = false)
    if original.respond_to? method
      true
    else
      super
    end
  end

  def save
    if valid?
      people.each do |person|
        i = self.original.clone
        i.update_attributes(:person => person, :user => @user)
        self.interactions += [i] # TODO: Figure out why self.interactions << i doesn't work
      end
      true
    else
      false
    end
  end

  def has_people
    unless self.person_ids.count > 0
      errors.add :person_ids_string, "Please add at least one person before saving"
    end
  end

  def interaction_valid
    unless !@original || @original.valid?
      @original.errors.each do |error,message|
        errors.add(error, message)
      end
    end
  end

end
