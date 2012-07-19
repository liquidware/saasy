# -*- encoding : utf-8 -*-
class AdvertsController < ApplicationController
  def index
  end
  
  def show
    @advert = Advert.find(params[:id])
    
    #only show 3 uploads
    (3 - @advert.assets.length).times { @advert.assets.build }
    
    respond_to do |format|
      format.html
      format.json { 
        render :json => @advert.assets.to_json(:only => [:name], :methods => [:source_url])
      }
    end 
  end
  
  def update
    @advert = Advert.find(params[:id])
    if @advert.update_attributes(params[:advert])
    # success
      msg = "Advert updated."
    else
    # error handling
      msg = "Error updating advert"
    end
    flash[:notice] = msg
    redirect_to :action => 'show'
  end
    
  def new
    @advert = Advert.new()
    5.times { @advert.assets.build }
  end 
end
