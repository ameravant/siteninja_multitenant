class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :domain
      t.string :title
      t.string :directory
      t.boolean :separate_db, :default => false
      t.integer :owner_id
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
