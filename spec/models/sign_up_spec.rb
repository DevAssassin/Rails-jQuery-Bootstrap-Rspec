require 'spec_helper'

describe SignUp do

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :email }
  %w(single max premium basic plus).each do |value|
    it { should allow_value(value).for(:plan) }
  end
  it { should_not allow_value("other").for(:plan) }
  it { should allow_value("some other sport").for(:other_sport_name) }

  context "signup object" do
    before(:each) do
      @signup = Fabricate(:SignUp)
    end

    it "should set account and program name when university name and sport name are provided" do
      @signup.program_name.should eql @signup.sport_name
      @signup.should be_valid
    end

    it "should return program name different from sport name when program name is provided" do
      @signup.program_name = "Womens Basketball"
      @signup.program_name.should_not eql @signup.sport_name
      @signup.should be_valid
    end

    it "sets paid to false by default" do
      @signup.paid.should be_false
    end

    it "returns true if sport is supported" do
      @signup.sport_is_supported?.should be_true
    end

    it "returns false for unsupported sport" do
      @signup.sport_name = "something else"
      @signup.sport_is_supported?.should be_false
    end

    it "returns true for supported sport with different displayed/class name" do
      silence_warnings do
        SignUp::SUPPORTED_SPORTS_ = SignUp::SUPPORTED_SPORTS
        SignUp::SUPPORTED_SPORTS = [ [ 'Some Sport', 'SomeSport'] ]
        @signup.sport_name = 'SomeSport'
        @signup.sport_is_supported?.should be_true
        SignUp::SUPPORTED_SPORTS = SignUp::SUPPORTED_SPORTS_
      end
    end

    context "when provisioning account" do

      before(:each) do
        ActionMailer::Base.deliveries = []
      end

      context "and sport is not supported" do
        before(:each) do
          @signup = Fabricate.build(:SignUp, :sport_name => "Quiddich")
          @signup.save(validate: false)
          SignUp.provision(@signup.email)
        end

        it "sends unknown account program email to scoutforce if program not supported" do
          deliveries = ActionMailer::Base.deliveries
          deliveries.should have(1).email
          deliveries.first.body.should include("ERROR_UNSUPPORTED_SPORT")
        end
      end

      context "and sport is supported" do
        before(:each) do
          @account, @program = SignUp.provision(@signup.email)
          @user = User.where(:email => @signup.email).first
        end

        it "provisions account with correct attributes" do
          @account.name.should == @signup.account_name
        end

        it "provisions correct program within account" do
          @program.name.should == @signup.program_name
          @program.account.should == @account
        end

        it "sets the sport class for the program" do
          @program.sport_class_name.should == "Baseball"
        end

        it "sets the program on the user" do
          @user.programs.to_a.should =~ [@program]
        end

        it "sends email to user when account is provisioned" do
          ActionMailer::Base.deliveries.should have(1).email
        end
      end
    end

  end

end
