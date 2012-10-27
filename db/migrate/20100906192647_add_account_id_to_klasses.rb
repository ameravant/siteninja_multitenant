class AddAccountIdToKlasses < ActiveRecord::Migration
  def self.up
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        begin
          add_column table_name.to_sym, :account_id, :integer, :default => 1
        rescue Exception => e
          
        end
        begin
          add_column table_name.to_sym, :master, :boolean, :default => false
        rescue Exception => e
          
        end
        begin
          add_index table_name.to_sym, :account_id
        rescue Exception => e
          
        end
      end
    end
  end

  def self.down
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        remove_column table_name.to_sym, :master
        remove_column table_name.to_sym, :account_id
      end
    end
  end
end
