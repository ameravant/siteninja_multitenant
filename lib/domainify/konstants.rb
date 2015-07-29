module Konstants
  TableNames = %w(activities article_categories articles assets color_schemes column_sections columns comments emails event_categories 
                   event_price_options event_registrations event_transactions events feature_templates featurable_sections
                   features feeds folders galleries gallery_categories images inquiries link_categories links menus newsletter_blasts 
                   newsletters pages people person_groups product_categories product_options products 
                   profiles redirects searches settings taggings templates testimonials themes users videos plan property property_search property_type region)
  Klasses = TableNames.reject{|t| !ActiveRecord::Base.connection.tables.include?(t)}.collect{|c| c.camelcase.singularize.constantize}
end
