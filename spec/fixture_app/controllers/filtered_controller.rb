class FilteredController < Rory::Controller
  before_action :pickle_something
  before_action :make_it_tasty
  after_action :rub_tummy
end