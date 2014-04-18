class Action < ActiveRecord::Base
  belongs_to :from, :class_name => 'User'
  belongs_to :to, :class_name => 'User'
  belongs_to :story
  belongs_to :comment
  belongs_to :vote

  attr_accessor :to_, :currency

  validate :check
  validates :amount, numericality: {greater_than: 0}
  validates :anonymous, inclusion: {in: [true, false]}

  before_create :amount_to_usd
  after_create :charge

  def check 
    if from == to
      errors.add :base, "Don't tip yourself..."
    end

    unless to || User.find_by(username: to_) 
      errors.add :to_, 'must be a user' 
    end
    
    if amount
      amount_to_usd
      if amount < 0.00000001
        errors.add :amount, 'must be at least 0.00000001 BTC' 
      elsif amount > from.balance
        errors.add :amount, 'is more Bitcoin than you have' 
      end
    end
  end

  def amount_to_usd
    if currency == 'USD'
      amount = usd_to_btc amount
    end
  end

  def tip?
    anonymous != nil
  end

  def charge 
    User.update_all ['balance = balance - ?', amount], id: from_id
    if to 
      amount = self.amount * (tip? && !from.is_admin?  ? 0.99 : 1)
      User.update_all ['balance = balance + ?', amount], id: to_id
    end

    if tip?
      if story
        Story.update_all ['tips_count = tips_count + 1'], id: story_id
      elsif comment
        Comment.update_all ['tips_count = tips_count + 1'], id: comment_id
      end
    end
  end
end
