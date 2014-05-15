class UsersController < ApplicationController
  before_filter :require_logged_in_user, :only => [:has_funds?]

  def show
    @showing_user = User.where(:username => params[:username]).first!
    @title = "User #{@showing_user.username}"
  end

  def tree
    @title = "Users"

    if params[:by].to_s == "karma"
      @users = User.order("karma DESC, id ASC").to_a
      @user_count = @users.length
      render :action => "list"
    else
      users = User.order("id DESC").to_a
      @user_count = users.length
      @users_by_parent = users.group_by(&:invited_by_user_id)
    end
  end

  def invite
    @title = "Pass Along an Invitation"
  end  
  
  def has_funds? 
    check = @user.check_balance 0.01 
    unless @user.is_admin? || check[0] 
      return render text: "Votes cost $0.01 (currently #{check[1]} Bitcoin).<br /><br /> Get Bitcoin by making good comments, or make a deposit and check on pending transactions at #{request.host_with_port}/balance.", status: 400
    end

    render text: 'ok'
  end
end
