class ForRealsController < Rory::Controller
  def srsly
    expose :gibbit => @params[:parbles]
    expose :but_when => 'again'
  end

  def switching
    if json_requested?
      render :json => { :a => 1 }
    else
      render 'for_reals/custom', :status => 404
    end
  end
end