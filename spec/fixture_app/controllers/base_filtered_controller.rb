class BaseFilteredController < Rory::Controller
  before_action :pickle_something, :except => [:eat]
  after_action :rub_tummy
  after_action :smile, :only => [:eat]
end