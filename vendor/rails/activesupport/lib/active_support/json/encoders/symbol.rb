# -*- encoding : utf-8 -*-
class Symbol
  def to_json(options = {}) #:nodoc:
    ActiveSupport::JSON.encode(to_s, options)
  end
end
