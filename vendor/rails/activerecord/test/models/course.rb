# -*- encoding : utf-8 -*-
class Course < ActiveRecord::Base
  has_many :entrants
end
