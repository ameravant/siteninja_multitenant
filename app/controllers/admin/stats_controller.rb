class Admin::StatsController < AdminController
  unloadable
  before_filter :super_admin_check
  add_breadcrumb "Accounts", "/admin/accounts"

  def index
    @tmplate.doctype == "5"
    @blocked_ips = @cms_config['site_settings']['blocked_ips'].blank? ? "" : @cms_config['site_settings']['blocked_ips'].gsub(" ", "").split(",").collect {|i| '"' + i + '"'}.join(",")
    if params[:account_id]
      @account = Account.find(params[:account_id])
      add_breadcrumb @account.title, admin_account_path(@account.id)
      if params[:remote_ip]
        add_breadcrumb "Stats", admin_account_stats_path(@account.id)
        add_breadcrumb params[:remote_ip]
        stats = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip = ?", @account.id, Time.now.beginning_of_month, params[:remote_ip]])
      else
        add_breadcrumb "Stats"
        stats = Stat.all(:order => "created_at DESC", :conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_month])
      end
      @stats = stats.paginate(:page => params[:page], :per_page => 100)
      
      @today = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day])
      @today_unique = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day]).map(&:remote_ip).uniq.size
      @yesterday = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).size
      @yesterday_unique = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).map(&:remote_ip).uniq.size
      
      @day_3 = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 1.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 2.days ]).size
      @day_3_unique = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 1.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 2.days ]).map(&:remote_ip).uniq.size
      
      
      @day_4 = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 2.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 3.days ]).size
      @day_4_unique = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 2.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 3.days ]).map(&:remote_ip).uniq.size
      
      
      @day_5 = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 3.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 4.days ]).size
      @day_5_unique = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 3.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 4.days ]).map(&:remote_ip).uniq.size
      
      
      @day_6 = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 4.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 5.days ]).size
      @day_6_unique = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 4.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 5.days ]).map(&:remote_ip).uniq.size
      
      
      @day_7 = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 5.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 6.days ]).size
      @day_7_unique = Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day - 5.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 6.days ]).map(&:remote_ip).uniq.size
      
      @month = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_month]).size
      @month_unique = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_month]).map(&:remote_ip).uniq.size
      @total = Stat.all(:conditions => ["account_id = ? and remote_ip not in (#{@blocked_ips})", @account.id]).size
      @total_unique = Stat.all(:conditions => ["account_id = ? and remote_ip not in (#{@blocked_ips})", @account.id]).map(&:remote_ip).uniq.size

    else
      if params[:remote_ip]
        add_breadcrumb params[:remote_ip]
        stats = Stat.all(:conditions => ["created_at > ? and remote_ip = ?", 30.days.ago, params[:remote_ip]])
      else
        add_breadcrumb "Stats"
        stats = Stat.all(:order => "created_at DESC", :conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", 30.days.ago])
      end
      @stats = stats.paginate(:page => params[:page], :per_page => 100)
      
      @today = Stat.all(:conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day])
      @today_unique = Stat.all(:conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day]).map(&:remote_ip).uniq.size
      @yesterday = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).size
      @yesterday_unique = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).map(&:remote_ip).uniq.size
      
      @day_3 = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 1.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 2.days ]).size
      @day_3_unique = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 1.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 2.days ]).map(&:remote_ip).uniq.size
      
      
      @day_4 = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 2.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 3.days ]).size
      @day_4_unique = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 2.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 3.days ]).map(&:remote_ip).uniq.size
      
      
      @day_5 = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 3.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 4.days ]).size
      @day_5_unique = Stat.all(:conditions => ["created_at < ? and created_at > ?", Time.now.beginning_of_day - 3.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 4.days ]).map(&:remote_ip).uniq.size
      
      
      @day_6 = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 4.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 5.days ]).size
      @day_6_unique = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 4.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 5.days ]).map(&:remote_ip).uniq.size
      
      
      @day_7 = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 5.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 6.days ]).size
      @day_7_unique = Stat.all(:conditions => ["created_at < ? and created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day - 5.days, Time.now.beginning_of_day - Time.now.beginning_of_day - 6.days ]).map(&:remote_ip).uniq.size
      
      @month = Stat.all(:conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_month]).size
      @month_unique = Stat.all(:conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_month]).map(&:remote_ip).uniq.size
      @total = Stat.all(:conditions => ["remote_ip not in (#{@blocked_ips})"]).size
      @total_unique = Stat.all(:conditions => ["remote_ip not in (#{@blocked_ips})"]).map(&:remote_ip).uniq.size
      
    end
  end
  
  def super_admin_check
    redirect_to '/' unless current_user && current_user.is_super_user
  end
  
end