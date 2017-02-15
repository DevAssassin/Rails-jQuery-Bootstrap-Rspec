module RecruitsHelper
  def has_projected_pos?(program)
    if program.is_a? Program
      program.sport_class.new.respond_to? :projected_position
    else
      false
    end
  end
end
