class AddAccountIdToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :account_id, :integer, :default => 1
    add_column :videos, :master, :boolean, :default => false
    add_index :videos, :account_id
  end

  def self.down
    remove_column :vidoes, :master
    remove_column :videos, :account_id
  end
end