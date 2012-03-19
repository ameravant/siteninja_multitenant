class Admin::StatsController < AdminController
  unloadable
  before_filter :super_admin_check, :except => 'stats_frame'
  add_breadcrumb "Accounts", "/admin/accounts"

  def index
    @tmplate.doctype == "5"
    @blocked_ips = CMS_CONFIG['site_settings']['blocked_ips'].blank? ? "" : CMS_CONFIG['site_settings']['blocked_ips'].gsub(" ", "").split(",").collect {|i| '"' + i + '"'}.join(",")
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
      
      @hours = []
      @hours_unique = []
      day = Time.now
      @hours << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", @account.id, 1.hour.ago, Time.now]).size
      @hours_unique << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", @account.id, 1.hour.ago, Time.now]).map(&:remote_ip).uniq.size
      23.times do |n|
        @hours << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", @account.id, (n.to_i+2).hours.ago, (n.to_i+1).hours.ago]).size
        @hours_unique << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", @account.id, (n.to_i+2).hours.ago, (n.to_i+1).hours.ago]).map(&:remote_ip).uniq.size
      end
      
      @days = []
      @days_unique = []
      @days << Stat.all(:conditions => ["account_id = ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day]).size
      @days_unique << Stat.all(:conditions => ["account_id = ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", @account.id, Time.now.beginning_of_day]).map(&:remote_ip).uniq.size
      6.times do |n|
        @days << Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", @account.id, (n.to_i).days.ago.beginning_of_day, (n.to_i+1).days.ago.beginning_of_day ]).size
        @days_unique << Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", @account.id, (n.to_i).days.ago.beginning_of_day, (n.to_i+1).days.ago.beginning_of_day ]).map(&:remote_ip).uniq.size
      end
      
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
      @hours = []
      @hours_unique = []
      day = Time.now
      @hours << Stat.all(:conditions => ["created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", 1.hour.ago, Time.now]).size
      @hours_unique << Stat.all(:conditions => ["created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", 1.hour.ago, Time.now]).map(&:remote_ip).uniq.size
      23.times do |n|
        @hours << Stat.all(:conditions => ["created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", (n.to_i+2).hours.ago, (n.to_i+1).hours.ago]).size
        @hours_unique << Stat.all(:conditions => ["created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", (n.to_i+2).hours.ago, (n.to_i+1).hours.ago]).map(&:remote_ip).uniq.size
      end
      
      
      @days = []
      @days_unique = []
      day = Stat.all(:conditions => ["created_at >= ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_day])
      @days << day.size
      @days_unique << day.map(&:remote_ip).uniq.size
      6.times do |n|
        day = Stat.all(:conditions => ["created_at < ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", (n.to_i).days.ago.beginning_of_day, (n.to_i+1).days.ago.beginning_of_day ])
        @days << day.size
        @days_unique << day.map(&:remote_ip).uniq.size
      end
      
      @month = Stat.all(:conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_month]).size
      @month_unique = Stat.all(:conditions => ["created_at > ? and remote_ip not in (#{@blocked_ips})", Time.now.beginning_of_month]).map(&:remote_ip).uniq.size
      @total = Stat.all(:conditions => ["remote_ip not in (#{@blocked_ips})"]).size
      @total_unique = Stat.all(:conditions => ["remote_ip not in (#{@blocked_ips})"]).map(&:remote_ip).uniq.size
      
    end
  end
  
  def stats_frame
    session[:layout] = "fancy"
    @blocked_ips = CMS_CONFIG['site_settings']['blocked_ips'].blank? ? "" : CMS_CONFIG['site_settings']['blocked_ips'].gsub(" ", "").split(",").collect {|i| '"' + i + '"'}.join(",")
    stats = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, (Time.now.beginning_of_month - 1.days)])
    @hours = []
    @hours_unique = []
    day = Time.now
    #@hours << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, 1.hour.ago, Time.now]).size
    #@hours_unique << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, 1.hour.ago, Time.now]).map(&:remote_ip).uniq.size
    hour = stats.reject{|x| !(x.created_at > 1.hour.ago and x.created_at <= Time.now)}
    @hours << hour.size
    @hours_unique << hour.map(&:remote_ip).uniq.size
    23.times do |n|
      # @hours << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, (n.to_i+2).hours.ago, (n.to_i+1).hours.ago]).size
      # @hours_unique << Stat.all(:conditions => ["account_id = ? and created_at > ? and created_at <= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, (n.to_i+2).hours.ago, (n.to_i+1).hours.ago]).map(&:remote_ip).uniq.size
      hour = stats.reject{|x| !(x.created_at > (n.to_i+2).hours.ago and x.created_at <= (n.to_i+1).hours.ago)}
      @hours << hour.size
      @hours_unique << hour.map(&:remote_ip).uniq.size
    end
    
    @days = []
    @days_unique = []
    # @days << Stat.all(:conditions => ["account_id = ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, Time.now.beginning_of_day]).size
    # @days_unique << Stat.all(:conditions => ["account_id = ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, Time.now.beginning_of_day]).map(&:remote_ip).uniq.size
    day = stats.reject{|x| !(x.created_at >= Time.now.beginning_of_day)}
    @days << day.size
    @days_unique << day.map(&:remote_ip).uniq.size
    6.times do |n|
      # @days << Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, (n.to_i).days.ago.beginning_of_day, (n.to_i+1).days.ago.beginning_of_day ]).size
      # @days_unique << Stat.all(:conditions => ["account_id = ? and created_at < ? and created_at >= ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, (n.to_i).days.ago.beginning_of_day, (n.to_i+1).days.ago.beginning_of_day ]).map(&:remote_ip).uniq.size
      day = stats.reject{|x| !(x.created_at < (n.to_i).days.ago.beginning_of_day and x.created_at >= (n.to_i+1).days.ago.beginning_of_day)}
      @days << day.size
      @days_unique << day.map(&:remote_ip).uniq.size
    end
    # @month = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, Time.now.beginning_of_month]).size
    # @month_unique = Stat.all(:conditions => ["account_id = ? and created_at > ? and remote_ip not in (#{@blocked_ips})", $CURRENT_ACCOUNT.id, Time.now.beginning_of_month]).map(&:remote_ip).uniq.size
    month = stats.reject{|x| !(x.created_at >= Time.now.beginning_of_month)}
    @month = month.size
    @month_unique = month.map(&:remote_ip).uniq.size
  end
  
  def super_admin_check
    redirect_to '/' unless current_user && current_user.is_super_user
  end
  
end