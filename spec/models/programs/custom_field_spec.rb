require 'spec_helper'

describe Programs::CustomField do
  let(:program) { Fabricate(:program_with_custom_fields) }
  context "when retrieving custom fields with section scope" do
    [:academic, :athletic, :personal].each do |section|
      it "should be able to return #{section} fields" do
        fields = program.custom_fields.section(section)
        fields.count.should == 1
        fields.first.section.should == section.to_s
      end
    end
  end
end
