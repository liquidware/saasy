# -*- encoding : utf-8 -*-
class <%= class_name %>Controller < ApplicationController
<% for action in actions -%>
  def <%= action %>
  end

<% end -%>
end
