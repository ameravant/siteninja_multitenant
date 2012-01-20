class Account < ActiveRecord::Base
  cattr_accessor :current
  validates_uniqueness_of :title
  validates_uniqueness_of :domain
  for klass in Klasses
    has_many klass.table_name.to_sym
  end
  has_one :setting
  named_scope :master, :conditions => "domain is null AND title = 'master'"

  def is_master?
    self.title == 'master' && self.domain.nil?
  end
  
  def name
    self.title
  end
end
