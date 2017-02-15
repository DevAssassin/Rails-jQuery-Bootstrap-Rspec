class DelegatorJob < Struct.new(:object_id, :object_type, :funktion, :args)

#  attr_accessor :object_id, :object_type, :funktion, :args

  def initialize(object, method, *args)
    super(object.id, object.class.name, method, args)
    raise NoMethodError, "undefined method `#{method}' for #{object}" unless object.respond_to?(method)
  end

  def enqueue(job)
    obj = get_object

    if obj.schedule
      obj.job = job
      obj.save
    end
  end

  def perform
    return get_object.send(funktion,*args)
  end

  def get_object
    Object.const_get(object_type).find(object_id)
  end
end
