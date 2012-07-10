# -*- encoding : utf-8 -*-
class LegacyThing < ActiveRecord::Base
  set_locking_column :version
end
