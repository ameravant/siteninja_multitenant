class Admin::AccountsController < AdminController
  unloadable
  before_filter :super_admin_check
  # before_filter :clear_current_account, :only => :index
  before_filter :find_account, :only => [:edit, :update, :delete]
  def index
    @accounts = Account.all
  end
  def new
    @account = Account.new
    @current_config = @cms_config
  end
  def edit
  end
  def create
    @account = Account.new(params[:account])
    @current_config = @cms_config
    Account.create(:title => "master") unless Account.count > 0
    @master_settings = Account.master.first.setting
    if @account.save
      add_cms_to_shared
      add_basic_data# if (!params[:oldaccount][:name].blank? or !params[:database][:database].blank?) #Don't add if there is an existing database for the account.
      redirect_to admin_accounts_path #{}"http://#{self.request.domain}"
      flash[:notice] = "You've successfully created an account"
    else
      render :new
    end
  end
  
  def update
    if @account.update_attributes(params[:account])
      path = RAILS_ROOT.gsub(/(\/data\/)(\S*)\/releases\S*/, '\1\2')
      cms_yml = YAML::load_file("#{RAILS_ROOT}/config/domains/#{@account.directory}/cms.yml")
      params[:cms_config][:modules_blog] ? cms_yml['modules']['blog'] = true : cms_yml['modules']['blog'] = false
      params[:cms_config][:modules_events] ? cms_yml['modules']['events'] = true : cms_yml['modules']['events'] = false
      params[:cms_config][:modules_newsletters] ? cms_yml['modules']['newsletters'] = true : cms_yml['modules']['newsletters'] = false
      params[:cms_config][:modules_documents] ? cms_yml['modules']['documents'] = true : cms_yml['modules']['documents'] = false
      params[:cms_config][:modules_product] ? cms_yml['modules']['product'] = true : cms_yml['modules']['product'] = false
      params[:cms_config][:modules_galleries] ? cms_yml['modules']['galleries'] = true : cms_yml['modules']['galleries'] = false
      params[:cms_config][:modules_links] ? cms_yml['modules']['links'] = true : cms_yml['modules']['links'] = false
      params[:cms_config][:modules_members] ? cms_yml['modules']['members'] = true : cms_yml['modules']['members'] = false
      params[:cms_config][:features_feature_box] ? cms_yml['features']['feature_box'] = true : cms_yml['features']['feature_box'] = false
      params[:cms_config][:features_testimonials] ? cms_yml['features']['testimonials'] = true : cms_yml['features']['testimonials'] = false
      File.open("#{RAILS_ROOT}/config/domains/#{@account.directory}/cms.yml", 'w') { |f| YAML.dump(cms_yml, f) }
      flash[:message] = "Account updated successfully."
      redirect_to admin_accounts_path
    else
      render :action => "edit"        
    end
  end
  
  private
  def add_cms_to_shared
    if Rails.env.production?
      @account.update_attributes(:directory => path_safe(@account.title))
      path = RAILS_ROOT.gsub(/(\/data\/)(\S*)\/releases\S*/, '\1\2')
      make_initial_domain_folder(path) unless File.exists?("#{path}/config/domains") && File.exists?("#{path}/shared/config")
      system "mkdir #{path}/current/config/domains/#{@account.directory}"
      system "mv #{path}/current/config/domains/#{@account.directory} #{path}/shared/config/domains/"
      system "ln -s #{path}/shared/config/domains/#{@account.directory} #{path}/current/config/domains/#{@account.directory}"
      if params[:oldaccount][:name].blank?
        system "cp #{path}/shared/config/cms.yml #{path}/shared/config/domains/#{@account.directory}/cms.yml"
      else
        system "cp /data/#{params[:oldaccount][:name]}/shared/config/cms.yml #{path}/shared/config/domains/#{@account.directory}/cms.yml"   
        system "cp /data/#{params[:oldaccount][:name]}/shared/config/database.yml #{path}/shared/config/domains/#{@account.directory}/database.yml"   
        @account.update_attributes(:separate_db => true)  
      end
      cms_yml = YAML::load_file("#{path}/current/config/domains/#{@account.directory}/cms.yml")
      cms_yml['website']['name'] = "#{@account.title.strip}"
      # Import Data From Existing Database
      if !params[:oldaccount][:name].blank? or !params[:database][:database].blank?
        cms_yml['site_settings']['secondary_database'] = true
      else
        params[:cms_config][:modules_blog] ? cms_yml['modules']['blog'] = true : cms_yml['modules']['blog'] = false
        params[:cms_config][:modules_events] ? cms_yml['modules']['events'] = true : cms_yml['modules']['events'] = false
        params[:cms_config][:modules_newsletters] ? cms_yml['modules']['newsletters'] = true : cms_yml['modules']['newsletters'] = false
        params[:cms_config][:modules_documents] ? cms_yml['modules']['documents'] = true : cms_yml['modules']['documents'] = false
        params[:cms_config][:modules_product] ? cms_yml['modules']['product'] = true : cms_yml['modules']['product'] = false
        params[:cms_config][:modules_galleries] ? cms_yml['modules']['galleries'] = true : cms_yml['modules']['galleries'] = false
        params[:cms_config][:modules_links] ? cms_yml['modules']['links'] = true : cms_yml['modules']['links'] = false
        params[:cms_config][:modules_members] ? cms_yml['modules']['members'] = true : cms_yml['modules']['members'] = false
        params[:cms_config][:features_feature_box] ? cms_yml['features']['feature_box'] = true : cms_yml['features']['feature_box'] = false
        params[:cms_config][:features_testimonials] ? cms_yml['features']['testimonials'] = true : cms_yml['features']['testimonials'] = false
      end
      File.open("#{path}/current/config/domains/#{@account.directory}/cms.yml", 'w') { |f| YAML.dump(cms_yml, f) }
      @database_yml = YAML::load_file("#{path}/current/config/database.yml")
      if !params[:oldaccount][:name].blank?
        @old_database_yml = YAML::load_file("#{path}/shared/config/domains/#{@account.directory}/database.yml")
        @database_yml[@account.directory] = {"adapter" => @old_database_yml['production']['adapter'], "database" => @old_database_yml['production']['database'], "host" => @old_database_yml['production']['host'], "username" => @old_database_yml['production']['username'], "password" => @old_database_yml['production']['password']}
      elsif !params[:database][:database].blank?
        @database_yml[@account.directory] = {"adapter" => params[:database][:adapter], "database" => params[:database][:database], "host" => params[:database][:host], "username" => params[:database][:username], "password" => params[:database][:password]}
      end
      File.open("#{path}/current/config/database.yml", 'w') { |f| YAML.dump(@database_yml, f) }
    else
      @account.update_attributes(:directory => path_safe(@account.title))
      path = RAILS_ROOT
      make_initial_domain_folder(path) unless File.exists?("#{path}/config/domains") && File.exists?("#{path}/shared/config")
      system "mkdir #{path}/config/domains/#{@account.directory}"
      system "cp #{path}/config/cms.yml #{path}/config/domains/#{@account.directory}/cms.yml"
      cms_yml = YAML::load_file("#{path}/config/domains/#{@account.directory}/cms.yml")
      cms_yml['website']['name'] = "#{@account.title.strip}"
      params[:cms_config][:modules_blog] ? cms_yml['modules']['blog'] = true : cms_yml['modules']['blog'] = false
      params[:cms_config][:modules_events] ? cms_yml['modules']['events'] = true : cms_yml['modules']['events'] = false
      params[:cms_config][:modules_newsletters] ? cms_yml['modules']['newsletters'] = true : cms_yml['modules']['newsletters'] = false
      params[:cms_config][:modules_documents] ? cms_yml['modules']['documents'] = true : cms_yml['modules']['documents'] = false
      params[:cms_config][:modules_product] ? cms_yml['modules']['product'] = true : cms_yml['modules']['product'] = false
      params[:cms_config][:modules_galleries] ? cms_yml['modules']['galleries'] = true : cms_yml['modules']['galleries'] = false
      params[:cms_config][:modules_links] ? cms_yml['modules']['links'] = true : cms_yml['modules']['links'] = false
      params[:cms_config][:modules_members] ? cms_yml['modules']['members'] = true : cms_yml['modules']['members'] = false
      params[:cms_config][:features_feature_box] ? cms_yml['features']['feature_box'] = true : cms_yml['features']['feature_box'] = false
      params[:cms_config][:features_testimonials] ? cms_yml['features']['testimonials'] = true : cms_yml['features']['testimonials'] = false
      File.open("#{path}/config/domains/#{@account.directory}/cms.yml", 'w') { |f| YAML.dump(cms_yml, f) }
      # @database_yml = YAML::load_file("#{path}/config/database.yml")
      # @database_yml[@account.directory] = {"adapter" => params[:database][:adapter], "database" => params[:database][:database], "host" => params[:database][:host], "username" => params[:database][:username], "password" => params[:database][:password]}
      # File.open("#{path}/config/database.yml", 'w') { |f| YAML.dump(@database_yml, f) }
    end
  end
  
  def make_initial_domain_folder(path)
    if Rails.env.production?
      system "mkdir #{path}/current/config/domains" unless File.exists?("#{path}/shared/config/domains")
      system "mv #{path}/current/config/domains #{path}/shared/config/domains" unless File.exists?("#{path}/shared/config/domains")
      system "ln -s #{path}/shared/config/domains #{path}/current/config/domains"
    else
      system "mkdir #{path}/config/domains" unless File.exists?("#{path}/shared/config/domains")
    end
  end
  def add_basic_data
    clear_current_account
    system "rake db:populate_domainify_min"
    s = @master_settings.clone
    s.account_id = @account.id
    s.save
  end
  def clear_current_account
    $CURRENT_ACCOUNT = nil
    $CURRENT_ACCOUNT = Account.find(params[:account_id]) if params[:account_id]
  end
  def super_admin_check
    redirect_to '/' unless current_user && current_user.is_super_user
  end
  def find_account
    @account = Account.find(params[:id])
    @current_config = YAML::load_file("#{RAILS_ROOT}/config/domains/#{@account.directory}/cms.yml")
  end
end