class Admin::StatsController < AdminController
  unloadable
  add_breadcrumb "Accounts", "/admin/accounts"

  def index
    add_breadcrumb "Stats"
    @account = Account.find(params[:account_id])
    @stats = @account.stats
  end
  
end