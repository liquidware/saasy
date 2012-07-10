# -*- encoding : utf-8 -*-
class PriceEstimate < ActiveRecord::Base
  belongs_to :estimate_of, :polymorphic => true
end
