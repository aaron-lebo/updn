class TipsController < ApplicationController
  before_filter :require_logged_in_user, only: [:new, :create, :item_create]

  def new 
    @title = 'Send Tip'
    @tip = Action.new
    if params[:to]
      @tip.to_ = params[:to]
    end
  end
  
  def create
    @title = 'Send Tip'
    @tip = Action.new tip_params
    to = User.find_by username: tip_params[:to_]  
    save_tip to, user_url(to), 'new'
  end

  def item_new 
    @tip = Action.new
    load_item    
  end
  
  def item_create
    @tip = Action.new tip_params 
    load_item    
    save_tip @item.user, request.original_url.gsub('/tips', ''), 'item_new' 
  end

private
  def tip_params
    params.require(:tip).permit :to_, :amount, :currency, :anonymous
  end
  
  def load_item
    if params[:comment_short_id]    
      comments = Comment.where short_id: params[:comment_short_id]
      @item = comments[0]
      if @user
        votes = Vote.comment_votes_by_user_for_comment_ids_hash(@user.id,
          comments.map{|c| c.id })
        @item.current_vote = votes[@item.id]
      end

      @tip.story = @item.story
      @tip.comment = @item
    else
      stories = Story.where short_id: params[:id]
      @item = stories[0]
      if @user
        votes = Vote.votes_by_user_for_stories_hash @user.id, stories.map(&:id) 
        @item.vote = votes[@item.id]
      end

      @tip.story = @item
    end
   
    story = stories ? @item : @item.story
    @title = 'Send Tip | ' + (story.can_be_seen_by_user?(@user) ? story.title : '[Story removed]')
  end

  def save_tip(to, url, action)    
    @tip.from = @user 
    @tip.to = to

    if @tip.save
      flash[:success] = "Your tip of #{btc_and_usd @tip.amount} has been sent to #{@tip.to.username}."
      redirect_to url
    else
      render action: action 
    end
  end
end
