# frozen_string_literal: true

class ExpensesController < ApplicationController
  include Authorization

  def index
    @expenses = @authenticated_user.expenses
  end

  def new
    @expense = Expense.new
  end

  def edit
    @expense = Expense.find(params[:id])
  end

  def create
    Expense.transaction do
      @expense = Expense.new(expense_params)
      @expense.user_id = @authenticated_user.id
      @expense.save

      # Create the relationship in FGA
      associate_user_to_expense(user_id: @expense.user_id, expense_id: @expense.id)
    end

    if @expense.valid?
      redirect_to expenses_path
    else
      render :new
    end
  end

  def update
    expense = Expense.find(params[:id])
    expense.update(expense_params)

    if expense.valid?
      redirect_to expenses_path
    else
      render :edit
    end
  end

  def destroy
    Expense.transaction do
      expense = Expense.find(params[:id])
      expense.delete

      disassociate_user_from_expense(user_id: expense.user_id, expense_id: expense.id)
    end
    redirect_to expenses_path
  end

  # Displays the approval queue for expenses. Managers only.
  def approval_queue
    head :unauthorized unless @authenticated_user.role == 'manager'
    @expenses = Expense.where(id: expense_approvals_for(user_id: @authenticated_user.id))
  end

  def approve_expense; end

  private

  def expense_params
    params.require(:expense).permit(:amount, :description)
  end
end
