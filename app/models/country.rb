class Country
  include Mongoid::Document

  add_indexes
  field :name

  references_many :states

  # Last item is used for the separator
  PRIORITY_LIST = ['United States of America','Canada','-------------']

  def self.list_for_select
    countries = self.asc(:name)

    # Prevent the countries in priority list to appear twice in the list
    priority_countries = countries.any_in(name: PRIORITY_LIST)
    country_arr = PRIORITY_LIST
    country_arr += (countries - priority_countries).collect{|country| country.name}
  end
end
