# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../scripts'

module Rails::Generator::Scripts
  class Generate < Base
    mandatory_options :command => :create
  end
end
