require 'spec_helper'
include Devise::TestHelpers

describe PeopleController do
  before do
    sign_in(Fabricate(:program_user))
  end

  describe "show a person that does not exist" do
    before do
      get :show, :id => "10001"
    end

    it { should respond_with 404 }
  end
end
