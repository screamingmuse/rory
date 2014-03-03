class ForRealsController < Rory::Controller
  def srsly
    expose :gibbit => @params[:parbles]
  end
end