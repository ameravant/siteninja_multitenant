
klasses = []
TableNames.each do |table_name|
  if ActiveRecord::Base.connection.tables.include?(table_name)
    klasses << table_name.to_sym
  end
end
namespace :admin do |admin|
  admin.resources :accounts, :member => { :destroy => :get } do |account|
    for klass in klasses
      account.resources klass
    end
    account.resources :stats
  end
  admin.resources :stats, :collection => { :stats_frame => :get } 
end
# for klass in klasses
#   resources klass, :belongs_to => :account
# end
    