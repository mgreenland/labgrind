class TransactionsController < ApplicationController
before_filter :require_user
  # GET /transactions
  # GET /transactions.xml
  def index
    @transactions = Transaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  def bystatus
    @transactions = Transaction.where(:status => params[:status].capitalize)

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def approve
    if params[:transaction_id] then
      t = Transaction.find(params[:transaction_id])
      t.status = "Complete"
      t.save
      t.approve
      redirect_to transactions_path
    end
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    if params[:item_id] then
      item = Item.find(params[:item_id])
      transaction = item.transactions.create(params[:transaction])
      path = item_path(item)
    elsif params[:user_id] then
      user = User.find(params[:user_id])
      transaction = user.transactions.create(params[:transaction])
      path = user_path(user)
    end

    if transaction then
      # What we got was a generic Transaction; we want the subclass
      # so that polymorphism can do its thing
      transaction = transaction.becomes(transaction.class_type.constantize)
      transaction.created
      redirect_to path
    end
  end

end