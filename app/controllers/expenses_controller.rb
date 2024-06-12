# frozen_string_literal: true

class ExpensesController < ApplicationController
  include Authorization

  before_action :check_manager_authz, only: %i[approval_queue approve deny]

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
    @expenses = Expense.where(
      id: expense_approvals_for(user_id: @authenticated_user.id),
      status: :submitted
    )
  end

  def approve
    expense = Expense.find(params[:id])

    if expense.nil?
      respond_to do |format|
        format.html { redirect_to expenses_approve_path, notice: 'Expense not found.' }
        format.json { render json: { error: 'Expense not found.' }, status: :not_found }
      end
    end

    expense.transaction do
      expense.status = :manager_approved
      expense.save

      # Add the teams who can approve to this expense in FGA
      Department.where(expense_approver: true).find_each do |dep|
        associate_team_to_expense(team_id: dep.id, expense_id: expense.id)
      end
    end

    redirect_to expenses_approve_path
  end

  def deny
    Expense.update(params[:id], status: :rejected)

    redirect_to expenses_approve_path
  end

  private

  def expense_params
    params.require(:expense).permit(:amount, :description)
  end

  def check_manager_authz
    head :unauthorized unless @authenticated_user.role == 'manager'
  end
end
