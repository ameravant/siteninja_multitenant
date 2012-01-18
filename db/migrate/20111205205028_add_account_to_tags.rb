class AddAccountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :account_id, :integer, :default => 1
    add_column :tags, :master, :boolean, :default => false
  end

  def self.down
    remove_column :tags, :master
    remove_column :tags, :account_id
  end
end