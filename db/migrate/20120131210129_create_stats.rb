class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.string  :remote_ip
      t.string  :referer
      t.string  :url
      t.integer :account_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :stats
  end
end
