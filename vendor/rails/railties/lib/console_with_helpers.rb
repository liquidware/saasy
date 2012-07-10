# -*- encoding : utf-8 -*-
def helper
  @helper ||= ApplicationController.helpers
end

@controller = ApplicationController.new
