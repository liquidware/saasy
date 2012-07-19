# -*- encoding : utf-8 -*-
class Advert < ActiveRecord::Base
  has_many :assets, :dependent => :destroy
  accepts_nested_attributes_for :assets, :allow_destroy => true
end
