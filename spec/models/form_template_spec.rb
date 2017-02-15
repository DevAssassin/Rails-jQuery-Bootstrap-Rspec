require 'spec_helper'

describe FormTemplate do
  context "styles is not parsable by Mustache" do
    before do
      subject.styles = "Hi, I am {{not valid"
    end

    it { should have(1).error_on(:styles) }
  end

  context "html is not parsable by Mustache" do
    before do
      subject.html = "Hi I am {{not valid"
    end

    it { should have(1).error_on(:html) }
  end

  context "rendering the template" do
    it "renders a very simple template" do
      template = FormTemplate.new
      template.html = "foo{{{content}}}bar"

      template.render("baz<p>").should == "foobaz<p>bar"
    end

    it "ignores superfluous fields" do
      template = FormTemplate.new
      template.html = "foo{{{content}}}bar{{boop}}"

      template.render("baz<p>").should == "foobaz<p>bar"
    end
  end

  context "displaying form inside template" do
    form = Fabricate(:form)
  end

end
