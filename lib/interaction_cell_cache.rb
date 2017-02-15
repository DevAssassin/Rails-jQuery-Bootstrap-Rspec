module InteractionCellCache
  extend ActiveSupport::Concern

  included do
    cache :list_item do |cell, options|
      i = options[:interaction]
      "#{i.id}-#{i.updated_at.to_s(:number)}"
    end
  end
end
