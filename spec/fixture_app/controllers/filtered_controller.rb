require_relative 'base_filtered_controller'

class FilteredController < BaseFilteredController
  before_action :make_it_tasty
  before_action :make_it_nutritious, :only => [:eat]
  after_action :sleep, :except => [:eat]

  def eat
  end
end