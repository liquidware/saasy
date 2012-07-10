# -*- encoding : utf-8 -*-
class MemberType < ActiveRecord::Base
  has_many :members
end
