require 'spec_helper'

describe Interactions::Rating do
  it "saves the rating to the recruit" do
    rating = Fabricate.build(:rating_interaction)
    recruit = rating.person

    rating.rating = 8
    rating.save

    recruit.reload
    recruit.rating(rating.user).should == 8
  end

  it "stores the previous rating in the interaction" do
    rating = Fabricate.build(:rating_interaction)
    recruit = rating.person
    recruit.rate(rating.user, 7)

    rating.rating = 8
    rating.save

    rating.old_rating.should == 7
  end
end
