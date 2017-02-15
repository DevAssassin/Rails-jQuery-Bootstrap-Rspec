class FormTemplate
  include Mongoid::Document
  add_indexes

  accepts_nested_attributes_for :assets

  embedded_in :account
  embeds_many :assets, :class_name => "EmailTemplateAsset"

  field :styles, :type => String
  field :html,   :type => String

  validates :styles, :mustache_parsable => true
  validates :html,   :mustache_parsable => true

  def render(content)
    Mustache.render(html, {:content => content}.merge(asset_hash))
  end

  def render_styles
    Mustache.render(styles, asset_hash)
  end

  private
  def asset_hash
    h = {}

    (assets || []).each_with_index do |asset, i|
      h["asset_#{i+1}".to_sym] = asset.asset.url if asset.asset?
    end

    h
  end

end
