# -*- encoding : utf-8 -*-
class EmailMxOnly < ActiveRecord::Base
  
  set_table_name :emails
  validates_email_veracity_of :address, :mx_only => true
  
end
