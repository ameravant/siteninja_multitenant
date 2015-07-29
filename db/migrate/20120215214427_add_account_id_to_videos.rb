class AddAccountIdToVideos < ActiveRecord::Migration
  def self.up
    begin
      add_column :videos, :account_id, :integer, :default => 1
    rescue Exception => e
      
    end
    begin
      add_column :videos, :master, :boolean, :default => false      
    rescue Exception => e
      
    end
    begin
      add_index :videos, :account_id
    rescue Exception => e
      
    end
  end

  def self.down
    remove_column :videos, :master
    remove_column :videos, :account_id
  end
end