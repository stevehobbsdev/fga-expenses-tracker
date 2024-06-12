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

      # If this user has no manager, go straight to finance for approval
      if @authenticated_user.manager_id.nil?
        Department.where(expense_approver: true).find_each do |dep|
          associate_team_to_expense(team_id: dep.id, expense_id: @expense.id)
        end

        @expense.update(status: :manager_approved)
      end
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
      status: %i[submitted manager_approved]
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

    next_status = case expense.status.to_sym
                  when :submitted
                    :manager_approved
                  when :manager_approved
                    :approved
                  end

    expense.transaction do
      # Just automatically approve if the user is an expense approver
      next_status = :approved if @authenticated_user.department.expense_approver?
      expense.update(status: next_status)

      # If this team can approve expenses, remove the team from the expense in FGA since this is the last stage
      if @authenticated_user.department.expense_approver?
        begin
          disassociate_team_from_expense(team_id: @authenticated_user.department_id, expense_id: expense.id)
        rescue
        end
      else
        # Add the teams who can approve to this expense in FGA
        Department.where(expense_approver: true).find_each do |dep|
          associate_team_to_expense(team_id: dep.id, expense_id: expense.id)
        end
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
    head :unauthorized unless @authenticated_user.role == 'manager' || @authenticated_user.department.expense_approver?
  end
end
