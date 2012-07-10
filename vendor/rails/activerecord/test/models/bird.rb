# -*- encoding : utf-8 -*-
class Bird < ActiveRecord::Base
  validates_presence_of :name
end
