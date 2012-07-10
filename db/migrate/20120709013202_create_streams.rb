# -*- encoding : utf-8 -*-
class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.string :name
      t.string :pid
      t.string :status
      t.string :sink
      t.string :source

      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end
