require 'spec_helper'

describe PersonSearch do
  context "with a basic program filter" do
    let(:scope) { Fabricate(:program) }
    let(:search) { PersonSearch.new(params, scope) }
    let!(:person) { Fabricate(:baseball_recruit, :program => scope) }
    let!(:other_person) { Fabricate(:baseball_recruit, :program => scope) }
    let(:params) { Hash.new }

    %w(school college club).each do |kind|
      context "and a #{kind}" do
        let!(:institution) { Fabricate(kind.to_sym) }
        context "and a string id" do
          let(:params) { { institution_id: institution.id.to_s} }
          let(:person) { Fabricate(:baseball_recruit, :program => scope, kind.to_sym => institution) }
          it "returns the recruits at the #{kind}" do
            search.search.to_a.should =~ [person]
          end
        end
        context "and a BSON::ObjectId" do
          let(:params) { { institution_id: institution.id} }
          let(:person) { Fabricate(:baseball_recruit, :program => scope, kind.to_sym => institution) }
          it "returns the recruits at the #{kind}" do
            search.search.to_a.should =~ [person]
          end
        end
      end
    end

    context "when sorting" do
      let(:params) { { sorts: { last_name: '1', first_name: '0' } } }

      it "sets the appropriate ordering" do
        sorts = search.search.options[:sort]
        # TODO this seems like it's diving too deeply into mongoid internals
        sorts.should == [[:last_name, :asc], [:first_name, :desc]]
      end

    end

    it "does not return unnamed people" do
      noname = Fabricate.build(:person, program: scope, first_name: nil, last_name: nil)
      noname.save(validate: false)

      search.search.to_a.should_not include(noname)
    end

    context "generating csv" do
      let(:csv) { search.each_csv.to_a }

      it "creates a csv for each record" do
        csv.should have(2).lines

        csv.first.should =~ /#{person.first_name}/
      end

      it "adds a header" do
        full_csv = search.to_csv

        full_csv.should have(3).lines
        full_csv.first.should =~ /First Name/
      end

      context "from recruits" do
        let(:params) { {:people => 'recruits'} }

        it "adds the appropriate header" do
          full_csv = search.to_csv

          full_csv.should have(3).lines
          full_csv.first.should =~ /gpa/i
          full_csv.first.should =~ /rbi/i
        end
      end
    end
  end

  context "when filtering by scopes" do
    let!(:program) { Fabricate(:program) }
    let(:account) { program.account }
    let!(:person) { Fabricate(:baseball_recruit, :program => program, :graduation_year => 2007) }
    let!(:other_person) { Fabricate(:baseball_recruit, :program => program, :graduation_year => 2014) }

    let!(:other_program) { Fabricate(:program, :account => account) }
    let!(:other_program_person) { Fabricate(:soccer_recruit, :program => other_program )}

    let!(:account_person) { Fabricate(:person, :account => account) }

    it "returns all people by default at the account level" do
      search = PersonSearch.new({:person_scope => ""}, account)

      search.search.to_a.should =~ [person, other_person, other_program_person, account_person]
    end

    it "returns only the current program's recruits at the program level" do
      search = PersonSearch.new({}, program)

      search.search.to_a.should =~ [person, other_person]
    end

    it "returns only account-level people" do
      search = PersonSearch.new({ :queries => {:person_scope => "Account"} }, account)

      search.search.to_a.should =~ [account_person]
    end

    it "returns program-level people" do
      search = PersonSearch.new({ :queries => {:person_scope => "Program"} }, account)

      search.search.to_a.should =~ [person, other_person, other_program_person]
    end

    it "returns people for a specific program" do
      search = PersonSearch.new({ :queries => {:person_scope => program.id.to_s} }, account)

      search.search.to_a.should =~ [person, other_person]
    end

    it "returns people for specific grad year" do
      search = PersonSearch.new({ :queries => {:grad_year_filter => 2007}}, program)
      search.search.to_a.should =~ [person]
    end
  end

  context "when searching" do
    let!(:program) { Fabricate(:program) }
    let!(:coach) { Fabricate(:coach, :program => program) }
    let!(:recruit1) { Fabricate(:baseball_recruit, :program => program, :first_name => "Larry", :watchers => [coach]) }
    let!(:recruit2) { Fabricate(:baseball_recruit, :program => program, :first_name => "Larry") }
    let!(:recruit3) { Fabricate(:baseball_recruit, :program => program, :first_name => "Curly", :watchers => [coach]) }

    context "for a recruit's full name" do
      it "returns recruits that match full name" do
        PersonSearch.new({:queries => {:search => recruit2.name}}, program).search.to_a.should =~ [recruit2]
      end
    end

    context "for recruits that match a query" do
      it "returns all recruits that match query" do
        PersonSearch.new({:queries => {:search => "Lar"}}, program).search.to_a.should =~ [recruit1,recruit2]
      end
    end

    context "for a specific coach's recruits" do
      it "returns all recruits that match coach" do
        PersonSearch.new({:queries => {:user_filter => coach.id.to_s}}, program).search.to_a.should =~ [recruit1,recruit3]
      end
    end

    context "for a specific coach's recruits that match a query" do
      it "returns all people that match query and coach" do
        PersonSearch.new({:queries => {:search => "Lar", :user_filter => coach.id.to_s}}, program).search.to_a.should =~ [recruit1]
      end
    end
    
    context "for unassigned recruits" do
      it "returns recruits without assigned watchers" do
        PersonSearch.new({ :people => 'recruits', :queries => {:user_filter => 'unassigned_only' }}, program).search.to_a.should =~ [recruit2]
      end
    end
  end
end
