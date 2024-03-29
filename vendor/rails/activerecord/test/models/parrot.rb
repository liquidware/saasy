# -*- encoding : utf-8 -*-
class Parrot < ActiveRecord::Base
  set_inheritance_column :parrot_sti_class
  has_and_belongs_to_many :pirates
  has_and_belongs_to_many :treasures
  has_many :loots, :as => :looter
  alias_attribute :title, :name

  validates_presence_of :name
end

class LiveParrot < Parrot
end

class DeadParrot < Parrot
  belongs_to :killer, :class_name => 'Pirate'
end
