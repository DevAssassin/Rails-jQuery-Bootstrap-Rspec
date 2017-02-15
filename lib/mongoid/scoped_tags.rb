module Mongoid
  module ScopedTags
    extend ActiveSupport::Concern

    included do
      set_callback :create, :after, :create_scoped_tags
      set_callback :save, :after, :upsert_scoped_tags
    end

    module ClassMethods

      def scope_criteria(scope)
        {(scope.is_a?(Account) ? :account_id : :program_id) => scope.id}
      end

      def scoped_tags_name(scope)
        scope.is_a?(Account) ? :account_tags_array : :program_tags_array
      end

      def scoped_tags_string_name(scope)
        scope.is_a?(Account) ? :account_tags : :program_tags
      end

      def tags_by_scope(scope)
        db.collection('scoped_tags').find({:_id => scope_criteria(scope)}).first.try('[]','value') || []
      end

      def save_scoped_tags(scope,tags)
        db.collection('scoped_tags').update({:_id => scope_criteria(scope)}, {'$addToSet' => {:value => { '$each' => tags } } }, :upsert => true)
      end

      def mass_add_tags(scope,people,tags)
        tags = convert_string_to_array(tags, get_tag_separator_for(scope.is_a?(Account) ? :account_tags : :program_tags)) unless tags.is_a?(Array)
        tags = clean_up_array(tags)
        db.collection('people').update({:_id => { '$in' => people.map(&:id) } }, { '$addToSet' => { scoped_tags_name(scope) => { '$each' => tags } } }, :multi => true)
        save_scoped_tags(scope, tags)
      end

      def rename_tag(scope,old,new)
        return if old == new || [old,new].any?(&:blank?)
        db.collection('people').update(scope_criteria(scope).merge({scoped_tags_name(scope) => old}), {'$addToSet' => { scoped_tags_name(scope) => new } }, :multi => true)
        db.collection('scoped_tags').update({:_id => scope_criteria(scope), :value => old}, { '$addToSet' => { :value => new } })
        delete_tags(scope, old)
      end

      def aggregate_tags!
        map = "function() {
          var person = this;
          if(person.program_id && person.program_tags_array) {
            var program_tags_array = person.program_tags_array
            if(typeof(program_tags_array) != 'object') {
              program_tags_array = [program_tags_array]
            }
            program_tags_array.forEach(function(tag) {
              var obj = {}; obj[tag] = 1;
              emit({'program_id': person.program_id}, obj);
            });
          }
          if (person.account_tags_array) {
            var account_tags_array = person.account_tags_array
            if(typeof(account_tags_array) != 'object') {
              account_tags_array = [account_tags_array]
            }
            account_tags_array.forEach(function(tag) {
              var obj = {}; obj[tag] = 1;
              emit({'account_id': person.account_id}, obj);
            });
          }
        }"

        reduce = "function(key, values) {
          var result = {};
          values.forEach(function(v) {
            for (var tag_name in v) {
              if(!result[tag_name]) {
                result[tag_name] = 0;
              }
              result[tag_name] += v[tag_name];
            }
          });
          return result;
        }"

        finalize = "function(key, tag_object) {
          var result = [];
          for(var tag in tag_object) {
            result.push(tag);
          }
          return result;
        }"

        collection.master.map_reduce(map, reduce, :finalize => finalize, :out => "scoped_tags")
      end

      def delete_tags(scope, *tags)
        unless tags.empty?
          db.collection('people').update(scope_criteria(scope), {'$pullAll' => { scoped_tags_name(scope) => tags } }, :multi => true)
          db.collection('scoped_tags').update({:_id => scope_criteria(scope)}, {'$pullAll' => { :value => tags } })
        end
      end

    end

    def tags_by_scope(scope)
      self.send(Person.scoped_tags_name(scope))
    end

    def add_tag(scope,tag)
      return if tag.blank?
      self.send("#{Person.scoped_tags_name(scope)}=", tags_by_scope(scope) + [tag])
    end

    def remove_tag(scope,tag)
      return if tag.blank?
      self.send("#{Person.scoped_tags_name(scope)}=", tags_by_scope(scope) - [tag])
    end

    def unapplied_tags_by_scope(scope)
      Person.tags_by_scope(scope) - self.tags_by_scope(scope)
    end

    private
    def has_changed_tags?(scope)
      changes.include?(Person.scoped_tags_name(scope).to_s)
    end

    def changed_tags(scope)
      changes[Person.scoped_tags_name(scope)].try(:map) { |t| t || [] }
    end

    def added_tags(scope)
      old, new = changed_tags(scope)
      return [] unless new && added = new - (old & new)
      added
    end

    def removed_tags(scope)
      old, new = changed_tags(scope)
      return [] unless old && removed = old - (old & new)
      removed.select { |tag| Person.db.collection('people').find( Person.scope_criteria(scope).merge( { Person.scoped_tags_name(scope) => tag } ) ).limit(1).count(true) == 0 } if removed || []
    end

    def create_scoped_tags
      [program,account].each do |scope|
        if scope && !has_changed_tags?(scope)
            Person.save_scoped_tags(scope, self.send(Person.scoped_tags_name(scope)))
        end
      end
    end

    def upsert_scoped_tags
      [program,account].each do |scope|
        if scope && has_changed_tags?(scope)
          Person.save_scoped_tags(scope, added_tags(scope)) if added_tags(scope)
          Person.delete_tags(scope, *removed_tags(scope)) if removed_tags(scope)
        end
      end
    end
  end
end
