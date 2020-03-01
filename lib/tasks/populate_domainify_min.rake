 ###################################################################
#
# description:   database populator task for development use
# dependencies:  Populator and Faker gems (use `sudo gem install`)
# usage:         `rake db:populate` from your application's root
#
###################################################################

namespace :db do
  desc "Populate database with minimum data for new site."
  task :populate_domainify_min => :environment do
    Account.create!(:title => "master") if Account.all.empty?
    $CURRENT_ACCOUNT = Account.last
    $MASTER_ACCOUNT = Account.first
    directory = Account.last.title.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
    if $CURRENT_ACCOUNT == $MASTER_ACCOUNT
      @cms_config = YAML::load_file("#{RAILS_ROOT}/config/cms.yml")
    else
      @cms_config = YAML::load_file("#{RAILS_ROOT}/config/domains/#{directory}/cms.yml")
    end
    @default_layout = Column.find(@cms_config['site_settings']['page_layout_id'])
    @default_privacy = Page.find_by_permalink("privacy-policy", :conditions => {:account_id => $MASTER_ACCOUNT.id})
    @default_privacy = @default_privacy.body.gsub("#name#", $CURRENT_ACCOUNT.title) if @default_privacy
    @default_terms = Page.find_by_permalink("terms-of-use", :conditions => {:account_id => $MASTER_ACCOUNT.id})
    @default_terms = @default_terms.body.gsub("#name#", $CURRENT_ACCOUNT.title) if @default_terms
    @default_accessibility = Page.find_by_permalink("accessibility", :conditions => {:account_id => $MASTER_ACCOUNT.id})
    @default_accessibility = @default_accessibility.body.gsub("#name#", $CURRENT_ACCOUNT.title) if @default_accessibility
      
    
    require 'populator'
    require 'faker'

    # if Rails.env.production?
    #   $DOMAIN_PATH = "http://#{$CURRENT_ACCOUNT}.title.#{@cms_config['website']['domain']}"
    # else
    #   $DOMAIN_PATH = "http://#{$CURRENT_ACCOUNT}.title.localhost:3000"
    # end
    
    def add_pages
      puts "Creating pages..."
      home = Page.create(:title => 'Home', :body => 'home',
        :meta_title => "Home", :permalink => "home", :can_delete => false, :position => 1, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @cms_config['site_settings']['homepage_layout_id'])
      Page.create(:title => 'About Us', :body => 'About', :meta_title => "About #{@cms_config['website']['name']}", :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @cms_config['site_settings']['blog_layout_id'])
      Page.create(:title => 'Blog', :meta_title => 'Blog', :body => "blog", :permalink => "blog", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id) if @cms_config['modules']['blog']
      Page.create(:title => 'Images', :meta_title => 'Galleries', :body => "galleries", :permalink => "galleries", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id) if @cms_config['modules']['galleries']
      Page.create(:title => 'Events', :meta_title => 'Events', :body => "events", :permalink => "events", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @cms_config['site_settings']['events_layout_id']) if @cms_config["modules"]["events"]
      Page.create(:title => 'Products', :meta_title => 'Products', :body => "Products", :permalink => "products", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @cms_config['site_settings']['products_layout_id']) if @cms_config['modules']['product']
      contact = Page.create( :title => 'Contact Us', :body => "<h1>Contact #{@cms_config['website']['name']}</h1>", :meta_title => "Contact #{@cms_config['website']['name']}", :permalink => "inquire", :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id)
      Page.create(:title => 'Members', :meta_title => 'members', :body => "members", :permalink => "members", :can_delete => true, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id) if @cms_config['modules']['members']
      Page.create(:title => 'Profiles', :meta_title => 'profiles', :body => "profiles", :permalink => "profiles", :can_delete => true, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id) if @cms_config['modules']['profiles']
      Page.create(:title => 'Links', :meta_title => 'Links', :body => "links", :permalink => "links", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @cms_config['site_settings']['links_layout_id']) if @cms_config['modules']['links']
      Page.create(:title => 'Testimonials', :body => 'Testimonials', :meta_title => 'Testimonials', :show_in_footer => true, :show_in_menu => false, :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id) if @cms_config['features']['testimonials']
      Page.create(:parent_id => contact.id, :title => 'Contact Us - Thank You', :body => 'Thank you for your inquiry. We usually respond within 24 hours.', :meta_title => "Message sent", :permalink => "inquiry_received", :status => 'hidden', :show_in_footer => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id)
      Page.create(:parent_id => contact.id, :title => 'Privacy Policy',:show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => @default_privacy ? @default_privace : 'This page can be helpful when creating a privacy policy <a href="http://www.freeprivacypolicy.com/privacy.php">http://www.freeprivacypolicy.com/privacy.php</a>', :meta_title => "Privacy Policy", :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id)
      Page.create(:parent_id => contact.id, :title => 'Terms of Use', :show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => @default_terms ? @default_terms : 'Terms of Use', :status => 'hidden', :meta_title => "Terms of Use", :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id)
      Page.create(:parent_id => contact.id, :title => 'Accessibility', :show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => @default_accessiblity ? @default_accessibility : 'Accessibility', :status => 'hidden', :meta_title => "Accessibility", :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id)
      Page.create(:title => 'Documents', :meta_title => 'Documents', :body => "documents", :permalink => "documents", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :main_column_id => @default_layout.id) if @cms_config['modules']['documents']



      if @cms_config['modules']['documents']
        Folder.create(:title => "Top Folder", :permalink => "top-folder", :can_delete => false)
      end
      for page in Page.all
        if page.menus.empty?
          menu = page.menus.new
          menu.account_id = $CURRENT_ACCOUNT.id
          menu.save
        end
      end
      for menu in Menu.all
        page = menu.navigatable
        unless page.parent_id.blank?
          parent_page = Page.find(page.parent_id)
          menu.parent_id = parent_page.menus.first.id
        end
        menu.position = page.position
        menu.footer_pos = page.footer_pos
        menu.show_in_footer = page.show_in_footer
        menu.can_delete = page.can_delete
        menu.status = page.status
        menu.show_in_main_menu = false if page.status == "hidden"
        menu.show_in_side_column = false if page.status == "hidden"
        menu.account_id = page.account_id
        menu.save
      end
    end

    puts 'Adding role groups...'

    admin = PersonGroup.create(:title => "Admin", :role => true, :public => false, :description => "Has access to all areas of the CMS.", :account_id => $CURRENT_ACCOUNT.id)
    author = PersonGroup.create(:title => "Author", :role => true, :public => false, :description => "Can write and publish their own articles.", :account_id => $CURRENT_ACCOUNT.id)
    editor = PersonGroup.create(:title => "Editor", :role => true, :public => false, :description => "Can write, edit, and publish any article, and moderates comments.", :account_id => $CURRENT_ACCOUNT.id)
    contributor = PersonGroup.create(:title => "Contributor", :role => true, :public => false, :description => "Can write their own articles, but cannot publish them.", :account_id => $CURRENT_ACCOUNT.id)
    moderator = PersonGroup.create(:title => "Moderator", :role => true, :public => false, :description => "Can moderate comments.", :account_id => $CURRENT_ACCOUNT.id)
    member = PersonGroup.create(:title => "Member", :role => true, :public => false, :description => "Has access to member areas.", :account_id => $CURRENT_ACCOUNT.id) if @cms_config['modules']['members']
    newsletter = PersonGroup.create(:title => "Newsletter", :role => false, :public => true, :description => "Subscribe to the newsletter.", :account_id => $CURRENT_ACCOUNT.id) if @cms_config['modules']['newsletters']

    puts 'Adding users...'

    # Create the default administrator. REMEMBER: Have the client change this username/password
    person = Person.create(:first_name => "admin", :last_name => "admin", :email => "admin-#{$CURRENT_ACCOUNT.id}@mailinator.com", :account_id => $CURRENT_ACCOUNT.id)
    person.person_groups << admin
    user = User.create(:login => 'admin', :password => 'admin', :password_confirmation => 'admin', :active => true, :account_id => $CURRENT_ACCOUNT.id)
    user.person_id = person.id
    user.save

    # # Create the Ameravant logins
    # michael = Person.create(:first_name => "Michael", :last_name => "Kramer", :email => "michael@ameravant.com", :account_id => $CURRENT_ACCOUNT.id)
    # michael.person_groups << admin
    # user = User.create(:login => "michael", :password => "123Mail", :password_confirmation => "123Mail", :active => true, :account_id => $CURRENT_ACCOUNT.id, :is_super_user => true)
    # user.is_super_user = true
    # user.person_id = michael.id
    # user.save
    # dave = Person.create(:first_name => "Dave", :last_name => "Myers", :email => "dave@ameravant.com", :account_id => $CURRENT_ACCOUNT.id)
    # dave.person_groups << admin
    # user = User.create(:login => "dave", :password => "123Mail", :password_confirmation => "123Mail", :active => true, :account_id => $CURRENT_ACCOUNT.id)
    # user.is_super_user = true
    # user.person_id = dave.id
    # user.save
    
    
    
    @temp = Template.new
    @temp_html = TemplateHtml.new
    @temp_css = TemplateStyle.new
      @color_scheme                         = ColorScheme.find(@cms_config['site_settings']['color_scheme_id'])
      @temp.title                           = "Default Template"
      @temp.head_script                     = @color_scheme.theme.head_script
      @temp.foot_script                     = @color_scheme.theme.foot_script
      @temp_css.stylesheet                      = @color_scheme.theme.stylesheet
      @temp_css.additional_styles               = @color_scheme.css
      @temp.layout_top                      = @color_scheme.theme.layout_top
      @temp.layout_bottom                   = @color_scheme.theme.layout_bottom
      @temp_html.article_show                    = @color_scheme.theme.article_show  
      @temp_html.articles_index                  = @color_scheme.theme.articles_index
      @temp_html.small_article_for_index         = @color_scheme.theme.small_article_for_index
      @temp_html.medium_article_for_index        = @color_scheme.theme.medium_article_for_index
      @temp_html.large_article_for_index         = @color_scheme.theme.large_article_for_index
      @temp.slideshow_overlay_position      = @color_scheme.theme.slideshow_overlay_position
      @temp.slideshow_background_color      = @color_scheme.theme.slideshow_background_color
      @temp.slideshow_height                = @color_scheme.theme.slideshow_height
      @temp.slideshow_width                 = @color_scheme.theme.slideshow_width
      @temp.slideshow_animation             = @color_scheme.theme.slideshow_animation
      @temp.slideshow_show_controls         = @color_scheme.theme.slideshow_show_controls
      @temp.slideshow_navigation            = @color_scheme.theme.slideshow_navigation
      @temp.slideshow_transition_speed      = @color_scheme.theme.slideshow_transition_speed
      @temp.slideshow_transition_delay      = @color_scheme.theme.slideshow_transition_delay
      @temp.wide_slideshow                  = @color_scheme.theme.wide_slideshow
      @temp.wide_slideshow_width            = @color_scheme.theme.wide_slideshow_width
      @temp.wide_slideshow_height           = @color_scheme.theme.wide_slideshow_height
      @temp.slideshow_border                = @color_scheme.theme.slideshow_border
      @temp.slideshow_height_standard       = @color_scheme.theme.slideshow_height_standard
      @temp.slideshow_height_tablet         = @color_scheme.theme.slideshow_height_tablet
      @temp.slideshow_height_mobile         = @color_scheme.theme.slideshow_height_mobile
      @temp.wide_slideshow_height_standard  = @color_scheme.theme.wide_slideshow_height_standard
      @temp.wide_slideshow_height_tablet    = @color_scheme.theme.wide_slideshow_height_tablet
      @temp.wide_slideshow_height_mobile    = @color_scheme.theme.wide_slideshow_height_mobile
      @temp_css.slideshow_styles                = @color_scheme.theme.slideshow_styles
      @temp.wide_slideshow_width_mobile     = @color_scheme.theme.wide_slideshow_width_mobile
      @temp.wide_slideshow_width_tablet     = @color_scheme.theme.wide_slideshow_width_tablet
      @temp.wide_slideshow_width_standard   = @color_scheme.theme.wide_slideshow_width_standard
      @temp.slideshow_width_mobile          = @color_scheme.theme.slideshow_width_mobile
      @temp.slideshow_width_tablet          = @color_scheme.theme.slideshow_width_tablet
      @temp.slideshow_width_standard        = @color_scheme.theme.slideshow_width_standard
      @temp.mobile_breakpoint               = @color_scheme.theme.mobile_breakpoint
      @temp.tablet_breakpoint               = @color_scheme.theme.tablet_breakpoint
      @temp.narrow_breakpoint               = @color_scheme.theme.narrow_breakpoint
      @temp.doctype                         = @color_scheme.theme.doctype
      @temp.master_layout_id                = @cms_config['site_settings']['master_layout_id']
      @temp.page_layout_id                  = @cms_config['site_settings']['page_layout_id']
      @temp.event_layout_id                 = @cms_config['site_settings']['event_layout_id']
      @temp.product_layout_id               = @cms_config['site_settings']['product_layout_id']
      @temp.image_layout_id                 = @cms_config['site_settings']['image_layout_id']
      @temp.editable                        = false
      @temp.global                          = true
      @temp.can_delete                      = false
      @temp.account_id                      = $CURRENT_ACCOUNT.id
      @temp.css_body_background_color             = @color_scheme.css_body_background_color
      @temp.css_content_background_color          = @color_scheme.css_content_background_color
      @temp.css_content_color                     = @color_scheme.css_content_color
      @temp.css_link_color                        = @color_scheme.css_link_color
      @temp.css_heading_1_color                   = @color_scheme.css_heading_1_color
      @temp.css_heading_2_color                   = @color_scheme.css_heading_2_color
      @temp.css_heading_3_color                   = @color_scheme.css_heading_3_color
      @temp.css_heading_4_color                   = @color_scheme.css_heading_4_color
      @temp.css_nav_color                         = @color_scheme.css_nav_color
      @temp.css_nav_background_color              = @color_scheme.css_nav_background_color
      @temp.css_nav_selected_color                = @color_scheme.css_nav_selected_color
      @temp.css_nav_selected_background_color     = @color_scheme.css_nav_selected_background_color
      @temp.css_sub_nav_color                     = @color_scheme.css_sub_nav_color
      @temp.css_sub_nav_background_color          = @color_scheme.css_sub_nav_background_color
      @temp.css_sub_nav_selected_color            = @color_scheme.css_sub_nav_selected_color
      @temp.css_sub_nav_selected_background_color = @color_scheme.css_sub_nav_selected_background_color
      @temp.css_custom_1                          = @color_scheme.css_custom_1
      @temp.css_custom_2                          = @color_scheme.css_custom_2
      @temp.css_custom_3                          = @color_scheme.css_custom_3
      @temp.css_custom_4                          = @color_scheme.css_custom_4
      @temp.css_custom_5                          = @color_scheme.css_custom_5
      @temp.css_custom_6                          = @color_scheme.css_custom_6
      @temp.css_custom_7                          = @color_scheme.css_custom_7
      @temp.css_custom_8                          = @color_scheme.css_custom_8
      @temp.css_custom_9                          = @color_scheme.css_custom_9
      @temp.css_custom_10                         = @color_scheme.css_custom_10
      @temp.css_custom_11                         = @color_scheme.css_custom_11
      @temp.css_custom_12                         = @color_scheme.css_custom_12
      @temp.css_sub_nav_visited_color             = @color_scheme.css_sub_nav_visited_color
      @temp.css_sub_nav_active_color              = @color_scheme.css_sub_nav_active_color
      @temp.css_sub_nav_hover_color               = @color_scheme.css_sub_nav_hover_color
      @temp.css_nav_visited_color                 = @color_scheme.css_nav_visited_color
      @temp.css_nav_active_color                  = @color_scheme.css_nav_active_color
      @temp.css_nav_hover_color                   = @color_scheme.css_nav_hover_color
      @temp.css_link_visited_color                = @color_scheme.css_link_visited_color
      @temp.css_link_active_color                 = @color_scheme.css_link_active_color
      @temp.css_link_hover_color                  = @color_scheme.css_link_hover_color
    @temp.save
    @temp_css.template_id = @temp.id
    @temp_css.save
    @temp_html.template_id = @temp.id
    @temp_html.save
    Setting.create(
      :newsletter_from_email => 'admin@ameravant.com',
      :footer_text => "<p>&copy; #YEAR# #{@cms_config['website']['name']}</p>",
      :inquiry_notification_email => "contact@#{@cms_config['website']['domain']}",
      :inquiry_confirmation_subject_line => "Inquiry",
      :inquiry_confirmation_message => "Thank you for your Inquiry. We usually respond to inquiries within 24 hours.",
      :comment_profanity_filter => true,
      :events_range => 3,
      :tracking_code => '<script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src=\'" + gaJsHost + "google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E"));
      </script>
      <script type="text/javascript">
      try {
      var pageTracker = _gat._getTracker("UA-7311013-1");
      pageTracker._trackPageview();
      } catch(err) {}</script>', 
      :account_id => $CURRENT_ACCOUNT.id,
      :template_id => @temp.id,
      :cms_yml => File.read("#{RAILS_ROOT}/config/domains/#{directory}/cms.yml")
    )
    
    add_pages
    FeaturableSection.create(:title => "Home Page Feature Box", :image_required => true, :site_wide => false, :account_id => $CURRENT_ACCOUNT.id)
# This adds Featurable Section backend needed for a new site to have a homepage feature box
    fs = FeaturableSection.first
    m = Menu.first
    if m and fs
      m.featurable_sections << fs
      m.save
    end
  end
end

