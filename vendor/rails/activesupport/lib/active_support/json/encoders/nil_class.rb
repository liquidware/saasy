# -*- encoding : utf-8 -*-
class NilClass
  def to_json(options = nil) #:nodoc:
    'null'
  end
end
