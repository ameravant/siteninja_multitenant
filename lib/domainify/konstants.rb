module Konstants
  TableNames = %w(article_categories articles assets column_sections columns comments emails event_categories 
                   event_price_options event_registrations event_transactions events featurable_sections
                   features folders galleries images inquiries link_categories links menus newsletter_blasts 
                   newsletters pages people person_groups product_categories product_options products 
                   profiles redirects searches settings taggings templates testimonials users)
  Klasses = TableNames.reject{|t| !ActiveRecord::Base.connection.tables.include?(t)}.collect{|c| c.camelcase.singularize.constantize}
end