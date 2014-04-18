class Transaction < ActiveRecord::Base
  belongs_to :user

  attr_accessor :to_confirmation, :currency, :confirm

  validates_confirmation_of :to
  validates :amount, numericality: {greater_than: 0}
  validate :balance
  validates :confirm, acceptance: true

  before_create :amount_to_usd
  after_create :create_withdrawal, unless: Proc.new {deposit}
  after_save :create_deposit, if: Proc.new {deposit && confirmations > 2}

  def balance 
    if amount
      amount_to_usd
      if amount < 0.0002
        errors.add :amount, 'must be at least 0.0002 BTC' 
      elsif amount > user.balance
        errors.add :amount, 'is more Bitcoin than you have' 
      end
    end
  end

  def amount_to_usd
    if currency == 'USD'
      amount = usd_to_btc amount
    end
  end

  def create_deposit 
    User.where(id: user_id).update_all ['balance = balance + ?', amount] 
    Bitcoin.move user_id.to_s, 'bank', amount.to_f
  end

  def create_withdrawal
    User.where(id: user_id).update_all ['balance = balance - ?', amount] 
  end
end
