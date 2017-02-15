class Admin::StatsController < AdminController

  def accounts
    @total = 0
    @stats = Stats::Sms.accounts.map do |s|
      @total += s['count'].to_i
      { :account => Account.where(:_id => s['account_id']).first, :count => s['count'].to_i }
    end
  end

  def programs
    @account = Account.find(params[:account_id])
    @total = 0
    @stats = Stats::Sms.programs(@account).map do |s|
      @total += s['count'].to_i
      { :program => Program.where(:_id => s['program_id']).first, :count => s['count'].to_i }
    end
  end

end
