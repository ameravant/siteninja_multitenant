class Admin::StatsController < AdminController
  unloadable
  add_breadcrumb "Accounts", "/admin/accounts"

  def index
    @account = Account.find(params[:account_id])
    add_breadcrumb @account.title, admin_account_path(@account.id)
    if params[:remote_ip]
      add_breadcrumb "Stats", admin_account_stats_path(@account.id)
      add_breadcrumb params[:remote_ip]
      stats = Stat.all(:order => "created_at DESC", :conditions => ['account_id = ? and created_at > ? and remote_ip = ?', @account.id, Time.now.beginning_of_month, params[:remote_ip]])
    else
      add_breadcrumb "Stats"
      stats = Stat.all(:order => "created_at DESC", :conditions => ['account_id = ? and created_at > ?', @account.id, Time.now.beginning_of_month])
    end
    @stats = stats.paginate(:page => params[:page], :per_page => 100)
  end
  
end