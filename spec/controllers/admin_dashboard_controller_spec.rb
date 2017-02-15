require 'spec_helper'

describe Admin::DashboardController do
  context 'trying to access when not signed in' do
    before do
      get(:index)
    end

    its(:status) { should == 404 }
  end
end
