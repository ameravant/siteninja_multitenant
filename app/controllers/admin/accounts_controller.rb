class Admin::AccountsController < AdminController
  unloadable
  before_filter :super_admin_check
  # before_filter :clear_current_account, :only => :index
  before_filter :find_account, :only => [:edit, :update, :delete]
  def index
    @accounts = Account.all
    @blocked_ips = @cms_config['site_settings']['blocked_ips'].blank? ? "" : @cms_config['site_settings']['blocked_ips'].gsub(" ", "").split(",").collect {|i| '"' + i + '"'}.join(",")
  end
  def new
    @account = Account.new
    @current_config = @cms_config
    @layouts = Column.all(:conditions => {:master => true, :column_location => "master"})
  end
  def edit
  end
  def create
    @account = Account.new(params[:account])
    @current_config = @cms_config
    @layouts = Column.all(:conditions => {:master => true, :column_location => "master"})
    Account.create(:title => "master") unless Account.count > 0
    @master_settings = Account.master.first.setting
    if @account.save

      add_cms_to_shared
      add_basic_data# if (!params[:oldaccount][:name].blank? or !params[:database][:database].blank?) #Don't add if there is an existing database for the account.


      directory = @account.title.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
      cms_config = YAML::load_file("#{RAILS_ROOT}/config/domains/#{directory}/cms.yml")
      @default_layout = Column.find(cms_config['site_settings']['page_layout_id'])
      @default_privacy = Page.find_by_permalink("privacy-policy").body.gsub("#name#", @account.title) if Page.find_by_permalink("privacy-policy")
      @default_terms = Page.find_by_permalink("terms-of-use").body.gsub("#name#", @account.title) if Page.find_by_permalink("terms-of-use")
      @default_accessibility = Page.find_by_permalink("accessibility").body.gsub("#name#", @account.title) if Page.find_by_permalink("accessibility")

      page = Page.create(:title => 'Accessibility1',:show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => @default_accessibility, :meta_title => "Accessibility1", :account_id => @account.id, :main_column_id => @default_layout.id)
      menu = page.menus.new
      menu.account_id = @account.id
      menu.show_in_main_menu = false
      menu.show_in_side_column = false
      menu.show_in_footer = true
      menu.save
      page = Page.create(:title => 'Privacy Policy',:show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => @default_privacy, :meta_title => "Privacy Policy", :account_id => @account.id, :main_column_id => @default_layout.id)
      menu = page.menus.new
      menu.account_id = @account.id
      menu.show_in_main_menu = false
      menu.show_in_side_column = false
      menu.show_in_footer = true
      menu.save
      page = Page.create(:title => 'Terms of Use', :show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => @default_terms, :status => 'hidden', :meta_title => "Terms of Use", :account_id => @account.id, :main_column_id => @default_layout.id)
      menu = page.menus.new
      menu.account_id = @account.id
      menu.show_in_main_menu = false
      menu.show_in_side_column = false
      menu.show_in_footer = true
      menu.save

      redirect_to admin_accounts_path #{}"http://#{self.request.domain}"
      flash[:notice] = "You've successfully created an account"

    else
      render :new
    end
  end
  
  def destroy
    @account = Account.find(params[:id])
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        records = eval("@account.#{table_name}")
        for record in records
          record.destroy
        end
      end
    end
    system "rm -rf #{RAILS_ROOT}/config/domains/#{@account.directory}"
    @account.destroy
    flash[:notice] = "Account has been deleted."
    redirect_to admin_accounts_path
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
      #system "ln -s #{path}/shared/config/domains/#{@account.directory} #{path}/current/config/domains/#{@account.directory}"
      # if params[:oldaccount][:name].blank?
        system "cp #{path}/shared/config/cms.yml #{path}/shared/config/domains/#{@account.directory}/cms.yml"
      # else
      #   system "cp /data/#{params[:oldaccount][:name]}/shared/config/cms.yml #{path}/shared/config/domains/#{@account.directory}/cms.yml"   
      #   system "cp /data/#{params[:oldaccount][:name]}/shared/config/database.yml #{path}/shared/config/domains/#{@account.directory}/database.yml"   
      #   @account.update_attributes(:separate_db => true)  
      # end
      cms_yml = YAML::load_file("#{path}/current/config/domains/#{@account.directory}/cms.yml")
      cms_yml['website']['name'] = "#{@account.title.strip}"
      # Import Data From Existing Database
      # if !params[:oldaccount][:name].blank? or !params[:database][:database].blank?
      #   cms_yml['site_settings']['secondary_database'] = true
      # else
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
        params[:cms_config][:enable_responsive_layouts] ? cms_yml['site_settings']['enable_responsive_layouts'] = true : cms_yml['site_settings']['enable_responsive_layouts'] = false
        cms_yml['site_settings']['color_scheme_id'] = params[:cms_config][:color_scheme_id]
        if params[:cms_config][:master_layout_id] != "Select a Master Layout"
          cms_yml['site_settings']['master_layout_id'] = params[:cms_config][:master_layout_id]
        else
          cms_yml['site_settings']['master_layout_id'] = ColorScheme.find(params[:cms_config][:color_scheme_id]).theme.master_layout_id
        end
        cms_yml['site_settings']['pages_account_id'] = params[:cms_config][:pages_account_id]
        cms_yml['site_settings']['page_layout_id'] = params[:cms_config][:page_layout_id]
        cms_yml['site_settings']['homepage_layout_id'] = params[:cms_config][:homepage_layout_id]
        cms_yml['site_settings']['event_layout_id'] = params[:cms_config][:event_layout_id]
        cms_yml['site_settings']['events_layout_id'] = params[:cms_config][:events_layout_id]
        cms_yml['site_settings']['product_layout_id'] = params[:cms_config][:product_layout_id]
        cms_yml['site_settings']['products_layout_id'] = params[:cms_config][:products_layout_id]
        cms_yml['site_settings']['links_layout_id'] = params[:cms_config][:links_layout_id]
        cms_yml['site_settings']['image_layout_id'] = params[:cms_config][:image_layout_id]
      # end
      File.open("#{path}/current/config/domains/#{@account.directory}/cms.yml", 'w') { |f| YAML.dump(cms_yml, f) }
      # @database_yml = YAML::load_file("#{path}/current/config/database.yml")
      # if !params[:oldaccount][:name].blank?
      #   @old_database_yml = YAML::load_file("#{path}/shared/config/domains/#{@account.directory}/database.yml")
      #   @database_yml[@account.directory] = {"adapter" => @old_database_yml['production']['adapter'], "database" => @old_database_yml['production']['database'], "host" => @old_database_yml['production']['host'], "username" => @old_database_yml['production']['username'], "password" => @old_database_yml['production']['password']}
      # elsif !params[:database][:database].blank?
      #   @database_yml[@account.directory] = {"adapter" => params[:database][:adapter], "database" => params[:database][:database], "host" => params[:database][:host], "username" => params[:database][:username], "password" => params[:database][:password]}
      # end
      # File.open("#{path}/current/config/database.yml", 'w') { |f| YAML.dump(@database_yml, f) }
    else
      @account.update_attributes(:directory => path_safe(@account.title))
      path = RAILS_ROOT
      if Rails.env.production?
        make_initial_domain_folder(path) unless File.exists?("#{path}/config/domains") && File.exists?("#{path}/shared/config")
      else
        make_initial_domain_folder(path) unless File.exists?("#{path}/config/domains")
      end
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
      params[:cms_config][:enable_responsive_layouts] ? cms_yml['site_settings']['enable_responsive_layouts'] = true : cms_yml['site_settings']['enable_responsive_layouts'] = false
      cms_yml['site_settings']['color_scheme_id'] = params[:cms_config][:color_scheme_id]
      cms_yml['site_settings']['master_layout_id'] = params[:cms_config][:master_layout_id]
      cms_yml['site_settings']['page_layout_id'] = params[:cms_config][:page_layout_id]
      cms_yml['site_settings']['homepage_layout_id'] = params[:cms_config][:homepage_layout_id]
      cms_yml['site_settings']['event_layout_id'] = params[:cms_config][:event_layout_id]
      cms_yml['site_settings']['events_layout_id'] = params[:cms_config][:events_layout_id]
      cms_yml['site_settings']['product_layout_id'] = params[:cms_config][:product_layout_id]
      cms_yml['site_settings']['products_layout_id'] = params[:cms_config][:products_layout_id]
      cms_yml['site_settings']['links_layout_id'] = params[:cms_config][:links_layout_id]
      cms_yml['site_settings']['image_layout_id'] = params[:cms_config][:image_layout_id]
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
    if params[:cms_config][:enable_responsive_layouts]
      system "rake db:populate_domainify_min"
    else
      system "rake db:populate_domainify_min_old"
      s = @master_settings.clone
      s.account_id = @account.id
      s.save
    end
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