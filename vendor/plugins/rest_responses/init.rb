# -*- encoding : utf-8 -*-
# Include hook code here
ActionController::Base.send :include, RestResponses::ControllerMethods
