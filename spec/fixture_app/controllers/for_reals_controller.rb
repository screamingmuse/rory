class ForRealsController < Rory::Controller
  def srsly
    expose :gibbit => @params[:parbles]
    expose :but_when => 'again'
  end
end