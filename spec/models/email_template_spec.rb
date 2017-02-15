require 'spec_helper'

describe EmailTemplate do
  context "rendering the template" do
    it "renders a very simple template" do
      template = EmailTemplate.new
      template.source = "foo{{{content}}}bar"

      template.render("baz<p>").should == "foobaz<p>bar"
    end

    it "ignores superfluous fields" do
      template = EmailTemplate.new
      template.source = "foo{{{content}}}bar{{boop}}"

      template.render("baz<p>").should == "foobaz<p>bar"
    end
  end

  context "source is not parsable by Mustache" do
    before do
      subject.source = "Hi, I am {{not valid"
    end

    it { should have(1).error_on(:source) }
  end
end
