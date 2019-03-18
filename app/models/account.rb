class Account < ActiveRecord::Base
  cattr_accessor :current
  has_many :stats
  has_and_belongs_to_many :shared_layouts, :class_name => "Column"
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
  
  def yml_path
    "#{RAILS_ROOT}/config/domains/#{self.directory}/cms.yml"
  end
  
  def name
    self.title
  end
end
