# -*- encoding : utf-8 -*-
class Subscription < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :book
end
