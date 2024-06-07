# frozen_string_literal: true

class ExpensesController < ApplicationController
  def index
    @expenses = @user.expenses
  end

  def new
    @expense = Expense.new
  end

  def edit
    @expense = Expense.find(params[:id])
  end

  def create
    @expense = Expense.new(expense_params)
    @user.expenses << @expense
    @user.save

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
    Expense.delete(params[:id])
    redirect_to expenses_path
  end

  private

  def expense_params
    params.require(:expense).permit(:amount, :description)
  end
end
