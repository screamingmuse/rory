require_relative 'base_filtered_controller'

class FilteredController < BaseFilteredController
  before_action :make_it_tasty
  after_action :sleep
end