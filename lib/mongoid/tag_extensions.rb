module Mongoid
  module TagExtensions
    extend ActiveSupport::Concern

    def add_tags(new_tags = [])
      new_tags = new_tags.split(",").map(&:strip) unless new_tags.is_a? Array

      old_tags = self.tags || []

      all_tags = (old_tags + new_tags).uniq.reject(&:blank?)

      self.tags = all_tags if all_tags != old_tags
    end

    def tag_list
      tags || []
    end

    def tags_string
      tag_list.join(", ")
    end

    def tags_string=(string)
      self.tags = string
    end

    module ClassMethods
      def convert_string_tags_to_array(_tags)
        (_tags).split(tags_separator).map(&:strip).reject(&:blank?)
      end

      def tags_by_program_with_weight(program)
        db.collection("program_tags").
          find("_id.program" => program.id).
          sort([["value", :desc], ["_id.tag", :asc]]).to_a.
          map{ |r| [r["_id"]["tag"], r["value"].to_i] }
      end

      def tags_by_program(program)
        tags_by_program_with_weight(program).map(&:first)
      end

      def aggregate_tags!
        return unless aggregate_tags?

        map = "function() {
        if (!this.#{tags_field}) {
          return;
        }

        for (index in this.#{tags_field}) {
          emit({tag: this.#{tags_field}[index], program: this.program_id}, 1);
        }
        }"

        reduce = "function(key, values) {
        var count = 0;

        for (index in values) {
          count += values[index]
        }

        return count;
        }"

        collection.master.map_reduce(map, reduce, :out => "program_tags")
        Mongoid.database.collection("program_tags").create_index("_id.program")
      end

      def mass_add_tags(people,tags)
        people = people.map(&:id)
        tags = tags.split(",").map(&:strip) unless tags.is_a? Array
        tags = tags.uniq.reject(&:blank?) || []

        collection.update(
          {"_id" => { "$in" => people } },
          {"$addToSet" => { "tags" => { "$each" => tags } } },
          {:multi => true}
        )

        aggregate_tags!
      end

      def delete_tags(program, *tags)
        collection.update(
          {"program_id" => program.id},
          {"$pullAll" => { "tags" => tags}},
          {:multi => true}
        )

        aggregate_tags!
      end

      def rename_tag(program, old, new)
        return if old == new

        collection.update(
          {"program_id" => program.id, "tags" => old},
          {"$addToSet" => { "tags" => new }},
          {:multi => true}
        )

        delete_tags(program, old)
      end
    end
  end
end

