class BaseFilteredController < Rory::Controller
  before_action :pickle_something, :except => [:eat]
  after_action :rub_tummy, :if => :horses_exist?
  after_action :smile, :only => [:eat]

  def horses_exist?
    params[:horses] != 'missing'
  end
end