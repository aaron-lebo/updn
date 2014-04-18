class BalanceController < ApplicationController
  before_filter :require_logged_in_user

  def index 
    @title = 'Actions | Balance'
    @cur_url = '/balance'

    @actions = Action.where('from_id = ? or to_id = ?', @user.id, @user.id).order 'id desc' 
  end  

  def transactions
    @title = 'Transactions | Balance'
    @cur_url = '/balance'

    @tx = Transaction.new
    @tx.to = @user.bitcoin_withdrawal
  end  

  def create
    @title = 'Transactions | Balance'
    @tx = Transaction.new transaction_params
    @tx.user = @user
    if @tx.save
      flash[:success] = "#{btc_and_usd @tx.amount} will be sent to #{@tx.to} within the next 3 days."
      redirect_to
    else
      render 'transactions'
    end
  end

private
  def transaction_params
    params.require(:transaction).permit :to, :to_confirmation, :amount, :currency, :confirm
  end
end
