require 'formtastic'

module Formtastic
  class CustomFieldsFormBuilder < FormBuilder

    def hidden_field?(field)
      @object.hidden_fields.include?(field.to_s) if @object.respond_to?(:hidden_fields)
    end

    def input(method, field_options = {})
      super(method, field_options) unless hidden_field?(method)
    end
  end
end
