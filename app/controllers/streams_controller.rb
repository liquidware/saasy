# -*- encoding : utf-8 -*-

class StreamsController < ApplicationController
  before_filter :login_required
	before_filter :find_stream, :only =>[ :show, :edit, :update, :unsuspend, :destroy]
  ssl_required :new, :create

  def index
    @streams = Stream.find(:all)
  end

  def create
    job1 = fork do
      loop { 
            `sudo gst-launch tcpserversrc host=10.10.229.207 port=800 ! multipartdemux ! jpegdec ! jpegenc ! multipartmux ! tcpserversink host=10.10.229.207 port=801 buffers-soft-max=3 recover-policy=1`
					#	`sudo gst-launch -v  videomixer name=mix ! ffmpegcolorspace ! jpegenc ! multipartmux ! tcpserversink host=10.10.229.207 port=801 buffers-soft-max=3 recover-policy=1 \
# videotestsrc ! video/x-raw-yuv, framerate=10/1, width=200, height=200 ! ffmpegcolorspace ! textoverlay font-desc="Sans 8" text="Live from Pluto" halign=left shaded-background=true auto-resize=false ! \
# videobox border-alpha=0 alpha=0.6 top=-2 bottom=-2 left=-2 right=-2 ! mix. \
# tcpserversrc host=10.10.229.207 port=800 ! multipartdemux ! jpegdec ! ffmpegcolorspace ! videobox border-alpha=0 ! mix.`
           }
    end
    @result = job1 
    Process.detach(job1)

    @stream = Stream.new
    @stream.pid = @result
    @stream.name = "My stream"
    @stream.sink = "gst-launch videotestsrc ! ffmpegcolorspace ! jpegenc ! multipartmux ! tcpclientsink host=\'ec2-107-20-52-37.compute-1.amazonaws.com\' port=800"
    @stream.source = "gst-launch tcpclientsrc host=\'ec2-107-20-52-37.compute-1.amazonaws.com\' port=801 ! multipartdemux ! jpegdec ! ffmpegcolorspace ! ximagesink"
    @stream.status = "ok"
    @stream.save!

    redirect_to :back
  end

  def show
  end
  
  def edit
    respond_to do |format|
        format.html # edit.html.erb
    end
  end

  def update
		if @stream.update_attributes(params[:stream])
  		# success
		else
  		# error handling
		end
		redirect_to '/'
  end

  def destroy
    stream = Stream.find(params[:id])
    logger.debug "stream = #{stream.pid}"
    logger.debug "#{RAILS_ROOT}/lib/pstree.sh"
    pstree = `sh #{RAILS_ROOT}/lib/pstree.sh #{stream.pid}`
    logger.debug "pstree= #{pstree}"
    `kill #{pstree}`
 
    stream.destroy
    redirect_to '/'
  end
 
  private

  def find_stream
    @stream = Stream.find(params[:id])
  end
end
