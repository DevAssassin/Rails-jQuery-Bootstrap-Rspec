class Programs::CustomField
  include Mongoid::Document

  embedded_in :program

  field :label
  field :section
  field :visible, :type => Boolean, :default => true

  default_scope order_by(:label.asc) 

  scope :section, ->(section) { where(:section => section.to_s) }

  Sections = {'Personal' => :personal, 'Athletic' => :athletic, 'Academic' => :academic}

  def name
    id.to_s
  end

  def label
    super.presence || "Untitled"
  end

end
