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
        :meta_title => "Home", :permalink => "home", :can_delete => false, :position => 1, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @homepage_column.id)
        Page.create(:title => 'About Us', :body => 'About', :meta_title => "About #{@cms_config['website']['name']}", :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id)
        Page.create(:title => 'Blog', :meta_title => 'Blog', :body => "blog", :permalink => "blog", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_article_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['blog']
        Page.create(:title => 'Images', :meta_title => 'Galleries', :body => "galleries", :permalink => "galleries", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['galleries']
        Page.create(:title => 'Events', :meta_title => 'Events', :body => "events", :permalink => "events", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config["modules"]["events"]
        Page.create(:title => 'Products', :meta_title => 'Products', :body => "Products", :permalink => "products", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['product']
        contact = Page.create( :title => 'Contact Us', :body => "<h1>Contact #{@cms_config['website']['name']}</h1>", :meta_title => "Contact #{@cms_config['website']['name']}", :permalink => "inquire", :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id)
        Page.create(:title => 'Members', :meta_title => 'members', :body => "members", :permalink => "members", :can_delete => true, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['members']
        Page.create(:title => 'Profiles', :meta_title => 'profiles', :body => "profiles", :permalink => "profiles", :can_delete => true, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['profiles']
        Page.create(:title => 'Links', :meta_title => 'Links', :body => "links", :permalink => "links", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['links']
        Page.create(:title => 'Testimonials', :body => 'Testimonials', :meta_title => 'Testimonials', :show_in_footer => true, :can_delete => false, :parent_id => home.id, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['features']['testimonials']
        Page.create(:parent_id => contact.id, :title => 'Contact Us - Thank You', :body => 'Thank you for your inquiry. We usually respond within 24 hours.', :meta_title => "Message sent", :permalink => "inquiry_received", :status => 'hidden', :show_in_footer => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id)
        Page.create(:parent_id => contact.id, :title => 'Privacy Policy',:show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => 'This page can be helpful when creating a privacy policy <a href="http://www.freeprivacypolicy.com/privacy.php">http://www.freeprivacypolicy.com/privacy.php</a>', :meta_title => "Privacy Policy", :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id)
        Page.create(:parent_id => contact.id, :title => 'Terms of Use', :show_articles => false,:show_events => false, :show_in_footer => true, :show_in_menu => false, :body => 'Terms of Use', :status => 'hidden', :meta_title => "Terms of Use", :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id)
        Page.create(:title => 'Documents', :meta_title => 'Documents', :body => "documents", :permalink => "documents", :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :main_column_id => @default_column.id) if @cms_config['modules']['documents']
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
    person = Person.create(:first_name => "admin", :last_name => "admin", :email => "admin@mailinator.com", :account_id => $CURRENT_ACCOUNT.id)
    person.person_groups << admin
    user = User.create(:login => 'admin', :password => 'admin', :password_confirmation => 'admin', :active => true, :account_id => $CURRENT_ACCOUNT.id)
    user.person_id = person.id
    user.save

    # Create the Ameravant logins
    michael = Person.create(:first_name => "Michael", :last_name => "Kramer", :email => "michael@ameravant.com", :account_id => $CURRENT_ACCOUNT.id)
    michael.person_groups << admin
    user = User.create(:login => "michael", :password => "123Mail", :password_confirmation => "123Mail", :active => true, :account_id => $CURRENT_ACCOUNT.id, :is_super_user => true)
    user.is_super_user = true
    user.person_id = michael.id
    user.save
    dave = Person.create(:first_name => "Dave", :last_name => "Myers", :email => "dave@ameravant.com", :account_id => $CURRENT_ACCOUNT.id)
    dave.person_groups << admin
    user = User.create(:login => "dave", :password => "123Mail", :password_confirmation => "123Mail", :active => true, :account_id => $CURRENT_ACCOUNT.id)
    user.is_super_user = true
    user.person_id = dave.id
    user.save
    
    
    feature = ColumnSectionType.first(:conditions => {:title => "Feature Box"})
    body_column = ColumnSectionType.first(:conditions => {:title => "Body Content"}) 
    @default_side = Column.create(:title => "Default Side Column", :account_id => $CURRENT_ACCOUNT.id, :column_location => "side_column", :can_delete => false)
    @default_article_side = Column.create(:title => "Default Article Side Column", :column_location => "side_column", :can_delete => false)
    @homepage_column = Column.create(:title => "Homepage", :column_location => "main_column", :can_delete => false)
    ColumnSection.create(:title => "Feature Box", :column_section_type_id => feature.id, :column_id => @homepage_column.id, :position => 1)
    ColumnSection.create(:title => "Body Content", :column_section_type_id => body_column.id, :column_id => @homepage_column.id, :position => 2)
    @default_column = Column.create(:title => "Default", :column_location => "main_column", :can_delete => false)
    ColumnSection.create(:title => "Body Content", :column_section_type_id => body_column.id, :column_id => @default_column.id, :position => 1)
    ColumnSection.create(:title => "Site Search", :section_type => "shared", :can_delete => false, :partial_name => "search_for_side_column", :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:partial_name => "search_for_side_column"}))
    ColumnSection.create(:title => "Newsletter Signup", :section_type => "newsletters", :can_delete => false, :partial_name => "signup_for_side_column", :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:partial_name => "signup_for_side_column"}).id) if @cms_config["modules"]["newsletters"]
    ColumnSection.create(:title => @cms_config['site_settings']['blog_title'], :section_type => "articles", :count => 5, :can_delete => false, :partial_name => "articles_for_side_column", :show_blurb => true, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:partial_name => "articles_for_side_column"}).id) if @cms_config["modules"]["blog"]
    ColumnSection.create(:title => "#{@cms_config['site_settings']['article_title']} Categories", :section_type => "article_categories", :count => 5, :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:partial_name => "article_categories_for_side_column"}).id) if @cms_config["modules"]["blog"]
    ColumnSection.create(:title => @cms_config["site_settings"]["events_title"], :section_type => "events", :count => 5, :can_delete => false, :show_blurb => true, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:partial_name => "events_for_side_column"}).id) if @cms_config["modules"]["events"]
    ColumnSection.create(:title => "Testimonial", :section_type => "testimonials", :count => 1, :can_delete => false, :account_id => $CURRENT_ACCOUNT.id, :column_id => @default_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:title => "Testimonial"}).id) if @cms_config["features"]["testimonials"]
    
    ColumnSection.create(:column_id => @default_article_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:title => "Article Categories"}).id, :count => 5, :title => "Article Categories")
    ColumnSection.create(:column_id => @default_article_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:title => "Article Archive"}).id, :count => 5, :title => "Article Archive")
    ColumnSection.create(:column_id => @default_article_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:title => "Article Authors"}).id, :count => 5, :title => "Article Authors")
    ColumnSection.create(:column_id => @default_article_side.id, :column_section_type_id => ColumnSectionType.first(:conditions => {:title => "Article Tags"}).id, :count => 5, :title => "Article Tags")

    
    
    
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
       :account_id => $CURRENT_ACCOUNT.id
     )
    Template.create(
      :title => "Global Template", :can_delete => false, :editable => false, :global => true,
      :layout_top => 
      '<div class="top-logo" id="wrapper-outer"> 
        <div id="wrapper-middle"> 
          <div id="wrapper-inner"> 
            <div id="header-outer"> 
              <div id="header-middle"> 
                <div id="header-inner"> 
                  {{header}}
                </div> 
              </div> 
            </div>
            {% if content_for_menu %}
              <div id="menu-outer">
                <div id="menu-middle">
                  <ul id="menu-inner">
                    {{menu}}
                  </ul>
                </div>
              </div>
            {% endif %}
            {{submenu}}
            {{banner}}
            <div id="pre-content-outer">
              <div id="pre-content-middle">
                <div id="pre-content-inner">
                  {{breadcrumbs}}
                </div>
              </div>
            </div>
            <div id="content-outer"> 
              <div id="content-middle">
                {% if content_for_side_column and content_for_side_column_2 %}
                  {% assign content-columns = "with-side-columns" %}
                {% elsif content_for_side_column or content_for_side_column_2 %}
                  {% if content_for_side_column %}
                    {% assign content-columns = "with-side-column" %}
                  {% else %}
                    {% assign content-columns = "with-side-column-2" %}
                  {% endif %}
                {% endif %}
                <div class="{{content-columns}}" id="content-inner">
                  {{wide_feature_box}}
                  {% if content_for_side_column_2 %}
                    <div class="sidebar" id="side-column-2">{{side_column_2}}</div>
                  {% endif %}
                  <div id="main-column">',
      :layout_bottom => 
      '            </div> 
                  {% if content_for_side_column %}
                    <div class="sidebar" id="side-column"> 
                      {{side_column}}
                    </div> 
                  {% endif %}
                  <div class="clear"></div> 
                </div> 
              </div> 
            </div> 
            <div id="footer-outer"> 
              <div id="footer-middle"> 
                <div id="footer-inner"> 
                  {{footer_menu}}
                  {{footer_text}}
                  <div id="footer_credits">
                    Powered by <a href="http://www.site-ninja.com">SiteNinja CMS</a>.
                  </div>
                </div> 
              </div> 
            </div> 
          </div> 
        </div> 
      </div>',
      :article_show => 
      '<h1>{{title}}</h1>
      <div class="article_posted_info">
        By {{author}} on {{date}} at {{time}} in {{article.list_of_article_categories}}
      </div>
      {% if article.show_description == true %}
        <div id="article-description">
          {{article.description}}
        </div>
      {% endif %}
      <div class="article_body">
        {{body}}
      </div>
      {{attachments}}
      <div id="share-options">
        {{sharethis}}
      </div>
      <div>{{comments}}</div>',
      :small_article_for_index => 
      '<h2><a href="{{article.path}}">{{article.title}}</a></h2>
      <div class="article_for_list">
        <div class="article_posted_info">
          <span class="hmenu">By {{article.author}} on {{article.date}} at {{article.time}} {{article.list_of_article_categories}}</span>
        </div>
        <div class="article_body">{{article.blurb | simple_format}}</div>
        <a href="/article/194-website-redesign-before-and-after">Read more...</a>
        <div class="clear"></div>
      </div>',
      :medium_article_for_index => 
      '<h2><a href="{{article.path}}">{{article.title}}</a></h2>
      <div class="article_for_list">
        {% if article.image_path %}
          <div class="images">
            <a href="{{article.path}}"><img src="{{article.image_path}}" alt="{{article.title}}" title="{{article.title}}" /></a>
            <div class="clear"></div>
          </div>
        {% endif %}
        <div class="article_posted_info">
          <span class="hmenu">By {{article.author}} on {{article.date}} at {{article.time}} {{article.list_of_article_categories}}</span>
        </div>
        <div class="article_body">{{article.blurb | simple_format}}</div>
        <a href="/article/194-website-redesign-before-and-after">Read more...</a>
        <div class="clear"></div>
      </div>',
      :large_article_for_index => 
      '<h2><a href="{{article.path}}">{{article.title}}</a></h2>
      <div class="article_for_list">
        {% if article.large_image_path %}
          <a href="{{article.path}}"><img src="{{article.large_image_path}}" alt="{{article.title}}" title="{{article.title}}" /></a>
        {% endif %}
        <div class="article_posted_info">
          <span class="hmenu">By {{article.author}} on {{article.date}} at {{article.time}} {{article.list_of_article_categories}}</span>
        </div>
        <div class="article_body">{{article.blurb | simple_format}}</div>
        <a href="/article/194-website-redesign-before-and-after">Read more...</a>
        <div class="clear"></div>
      </div>',
      :articles_index =>
      '<h1>
        {% if tag %}
          Articles by tag: {{ tag }}
        {% elsif author %}
          Articles by author: {{ author }}
        {% elsif month %}
          Articles by month: {{ month }}
        {% else %}
          {{ blog_title }}
        {% endif %}
      </h1>
      {{ articles_list }}',
      :account_id => $CURRENT_ACCOUNT.id
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

