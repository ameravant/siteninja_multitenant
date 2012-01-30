class AddLegacyIdToAccounts < ActiveRecord::Migration
  def self.up
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        add_column table_name.to_sym, :legacy_id, :integer
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
