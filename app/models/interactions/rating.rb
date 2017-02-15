class Interactions::Rating < Interaction
  field :rating, :type => Integer
  field :old_rating, :type => Integer

  before_create :set_old_rating_from_recruit
  before_create :set_rating_on_recruit

  private
  def set_rating_on_recruit
    if person
      person.rate(user, rating)
      person.save
    end
  end

  def set_old_rating_from_recruit
    if person
      if person.common_rating.nil?
        self.old_rating = person.avg_rating
      else
        self.old_rating = person.common_rating
      end
      #self.old_rating = person.rating(user)
      person.save
    end
  end
end