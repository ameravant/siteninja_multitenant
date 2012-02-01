class Admin::StatsController < AdminController
  unloadable
  add_breadcrumb "Accounts", "/admin/accounts"

  def index
    if params[:account_id]
      @account = Account.find(params[:account_id])
      add_breadcrumb @account.title, admin_account_path(@account.id)
      if params[:remote_ip]
        add_breadcrumb "Stats", admin_account_stats_path(@account.id)
        add_breadcrumb params[:remote_ip]
        stats = Stat.all(:conditions => ['account_id = ? and created_at > ? and remote_ip = ?', @account.id, Time.now.beginning_of_month, params[:remote_ip]])
      else
        add_breadcrumb "Stats"
        stats = Stat.all(:order => "created_at DESC", :conditions => ['account_id = ? and created_at > ?', @account.id, Time.now.beginning_of_month])
      end
      @stats = stats.paginate(:page => params[:page], :per_page => 100)
      
      @today = Stat.all(:conditions => ['account_id = ? and created_at > ?', @account.id, Time.now.beginning_of_day])
      @today_unique = Stat.all(:conditions => ['account_id = ? and created_at > ?', @account.id, Time.now.beginning_of_day]).map(&:remote_ip).uniq.size
      @yesterday = Stat.all(:conditions => ['account_id = ? and created_at < ? and created_at > ?', @account.id, Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).size
      @yesterday_unique = Stat.all(:conditions => ['account_id = ? and created_at < ? and created_at > ?', @account.id, Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).map(&:remote_ip).uniq.size
      @month = Stat.all(:conditions => ['account_id = ? and created_at > ?', @account.id, Time.now.beginning_of_month]).size
      @month_unique = Stat.all(:conditions => ['account_id = ? and created_at > ?', @account.id, Time.now.beginning_of_month]).map(&:remote_ip).uniq.size
      @total = Stat.all(:conditions => {:account_id => @account.id}).size
      @total_unique = Stat.all(:conditions => {:account_id => @account.id}).map(&:remote_ip).uniq.size

    else
      if params[:remote_ip]
        add_breadcrumb params[:remote_ip]
        stats = Stat.all(:conditions => ['created_at > ? and remote_ip = ?', 30.days.ago, params[:remote_ip]])
      else
        add_breadcrumb "Stats"
        stats = Stat.all(:order => "created_at DESC", :conditions => ['created_at > ?', 30.days.ago])
      end
      @stats = stats.paginate(:page => params[:page], :per_page => 100)
      
      @today = Stat.all(:conditions => ['created_at > ?', Time.now.beginning_of_day])
      @today_unique = Stat.all(:conditions => ['created_at > ?', Time.now.beginning_of_day]).map(&:remote_ip).uniq.size
      @yesterday = Stat.all(:conditions => ['created_at < ? and created_at > ?', Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).size
      @yesterday_unique = Stat.all(:conditions => ['created_at < ? and created_at > ?', Time.now.beginning_of_day, Time.now.beginning_of_day - Time.now.beginning_of_day - 1.days ]).map(&:remote_ip).uniq.size
      @month = Stat.all(:conditions => ['created_at > ?', Time.now.beginning_of_month]).size
      @month_unique = Stat.all(:conditions => ['created_at > ?', Time.now.beginning_of_month]).map(&:remote_ip).uniq.size
      @total = Stat.all.size
      @total_unique = Stat.all.map(&:remote_ip).uniq.size
      
    end
  end
  
end