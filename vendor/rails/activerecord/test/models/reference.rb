# -*- encoding : utf-8 -*-
class Reference < ActiveRecord::Base
  belongs_to :person
  belongs_to :job
end
