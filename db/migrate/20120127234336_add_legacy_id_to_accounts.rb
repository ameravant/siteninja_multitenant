class AddLegacyIdToAccounts < ActiveRecord::Migration
  def self.up
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        begin
          add_column table_name.to_sym, :legacy_id, :integer
        rescue Exception => e
          
        end
      end
    end
  end

  def self.down
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        remove_column table_name.to_sym, :legacy_id
      end
    end
  end
end
