# -*- encoding : utf-8 -*-
#
# Demonstrates basic image embedding and positioning functionality.
# For positioning images alongside flowing text, see the image_flow.rb
# example.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"
   
Prawn::Document.generate("basic_images.pdf", :page_layout => :landscape) do     
  pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
  image pigs, :at => [50,450], :scale => 0.5                                       
  
  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"
  image stef, :at => [75, 75] 
  
  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"
  image stef, :at => [500, 400], :width => 200, :height => 200 
  
  text "Please enjoy the pigs", :size => 36, :at => [200,15]   
  
  ruport = "#{Prawn::BASEDIR}/data/images/ruport.png"  
  image ruport, :at => [400,200], :width => 150 

  ruport = "#{Prawn::BASEDIR}/data/images/ruport_transparent.png"  
  image ruport, :at => [50,525] 
end
