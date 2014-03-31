class BaseFilteredController < Rory::Controller
  before_action :pickle_something
  after_action :rub_tummy
end