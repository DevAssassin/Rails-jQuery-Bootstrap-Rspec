require 'spec_helper'

describe Mongoid::ScopedTags do
  ['account','program'].each do |scope_type|
    context "for #{scope_type} tags" do
      let(:scope) { Fabricate(scope_type.to_sym) }
      context "when adding tags" do
        let!(:person) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        it "returns correct tags" do
          Person.tags_by_scope(scope).should =~ ['foo','bar']
        end
      end
      context "when removing tags" do
        let!(:person1) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'one, two') }
        let!(:person2) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'two') }
        it "deletes tag if no other people have that tag" do
          person1.update_attribute("#{scope_type}_tags_array",['two'])
          Person.tags_by_scope(scope).should =~ ['two']
        end
        it "doesn't delete tag if others have that tag" do
          person1.update_attribute("#{scope_type}_tags_array",['one'])
          Person.tags_by_scope(scope).should =~ ['one','two']
        end
      end
      context "when mass adding tags" do
        let(:people) { 2.times.map { Fabricate(:person, :"#{scope_type}" => scope) } }
        let(:tags) { 3.times.map { |n| "Tag#{n}" } }
        before(:each) { Person.mass_add_tags(scope,people,tags) }
        it "sets the tags on each person" do
          people.each do |person|
            person.reload.send("#{scope_type}_tags_array").should =~ tags
          end
        end
        it "aggregates the tags" do
          Person.tags_by_scope(scope).should =~ tags
        end
        it "shouldn't fail with blank or nil tags" do
          lambda { Person.mass_add_tags(scope,people,["",nil]) }.should_not raise_error
        end
      end
      context "when deleting tags" do
        let!(:person1) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        let!(:person2) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'abc, foo, xyz') }
        before(:each) { Person.delete_tags(scope,'foo') }
        it "deletes tag from people tag arrays" do
          person1.reload.send("#{scope_type}_tags_array").should =~ ['bar']
          person2.reload.send("#{scope_type}_tags_array").should =~ ['abc','xyz']
        end
        it "deletes tag from aggregated tags" do
          Person.tags_by_scope(scope).should =~ ['bar','abc','xyz']
        end
      end
      context "when renaming a tag" do
        let!(:person) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        let!(:other) { Fabricate(:person, :"#{scope_type}" => scope) }
        context "with valid data" do
          before(:each) { Person.rename_tag(scope,'bar','baz') }
          it "updates people's tag array" do
            person.reload.send("#{scope_type}_tags_array").should =~ ['foo','baz']
          end
          it "updates the aggregated tags" do
            Person.tags_by_scope(scope).should =~ ['foo','baz']
          end
          it "doesn't tag other people with that tag" do
            other.reload.send("#{scope_type}_tags_array").should =~ []
          end
        end
        context "with invalid data" do
          after(:each) { person.reload.send("#{scope_type}_tags_array").should =~ ['foo','bar'] }
          it "should not allow renaming a tag to a blank string" do
            Person.rename_tag(scope,'bar','')
          end
          it "should not allow renaming a blank string" do
            Person.rename_tag(scope,'','baz')
          end
          it "should not allow renaming a tag to an array" do
            Person.rename_tag(scope,'',['baz'])
          end
        end
      end
      context "when aggregating all tags" do
        let!(:person1) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        let!(:person2) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'baz, bar') }
        let!(:person3) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, abc') }
        it "should overwrite existing aggregated tags" do
          Person.save_scoped_tags(scope,['tag1','tag2','tag3'])
          Person.tags_by_scope(scope).should =~ ['foo','bar','baz','abc','tag1','tag2','tag3']
          Person.aggregate_tags!
          Person.tags_by_scope(scope).should =~ ['foo','bar','baz','abc']
        end
      end
      context "when adding a tag to a person" do
        let!(:person1) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        it "should add the tag" do
          person1.add_tag(scope,'baz')
          person1.tags_by_scope(scope).should =~ ['foo','bar','baz']
        end
        it "should not allow nil values" do
          person1.add_tag(scope,nil)
          person1.tags_by_scope(scope).should =~ ['foo','bar']
        end
      end
      context "when removing a tag from a person" do
        let!(:person1) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        it "should remove the tag" do
          person1.remove_tag(scope,'foo')
          person1.tags_by_scope(scope).should =~ ['bar']
        end
        it "should not allow nil values" do
          person1.remove_tag(scope,nil)
          person1.tags_by_scope(scope).should =~ ['foo','bar']
        end
      end
      context "when retrieving tags not applied to a person" do
        let!(:person1) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'tag1, tag2') }
        let!(:person2) { Fabricate(:person, :"#{scope_type}" => scope, :"#{scope_type}_tags" => 'foo, bar') }
        it "should return only tags not applied" do
          person2.unapplied_tags_by_scope(scope).should =~ ['tag1','tag2']
        end
      end
    end
  end
end
