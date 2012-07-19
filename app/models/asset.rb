# -*- encoding : utf-8 -*-
class Asset < ActiveRecord::Base
  belongs_to :advert
  has_attached_file :source,
                    :styles => { :thumb    => '100x100#',
                                 :small   => '300x300>',
                                 :large    => '600x600>' }
  def source_url
    source.url(:original)
  end
end
