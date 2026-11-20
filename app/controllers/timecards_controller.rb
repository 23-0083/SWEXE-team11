
require "csv"

class TimecardsController < ApplicationController
  before_action :require_admin, only: [:update, :destroy]

  def index
    @month = params[:month].to_s.match?(/\A\d{4}-(0[1-9]|1[0-2])\z/) ?
      params[:month] : Date.current.strftime("%Y-%m")

    start_date = Date.strptime(@month, "%Y-%m")
    @employees = Employee.order(:employee_code)
    @employee_id = params[:employee_id].to_s

    @timecards = Timecard.includes(:employee)
                         .where(work_date: start_date..start_date.end_of_month)
                         .order(:work_date, :clock_in)

    if @employee_id.present?
      @timecards = @timecards.where(employee_id: @employee_id)
    end

    @total_minutes = @timecards.sum { |card| card.work_minutes.to_i }

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@timecards),
                  filename: "timecards-#{@month}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  def update
    card = Timecard.find(params[:id])

    if card.update(timecard_params)
      redirect_to timecards_path, notice: "勤務履歴を更新しました"
    else
      redirect_to timecards_path,
                  alert: card.errors.full_messages.join(", ")
    end
  end

  def destroy
    card = Timecard.find(params[:id])
    card.destroy!

    redirect_to timecards_path, notice: "勤務履歴を削除しました"
  end

  private

  def require_admin
    return if session[:admin_logged_in] == true

    redirect_to "/admin/login?next=#{CGI.escape(request.path)}",
                alert: "管理者ログインが必要です"
  end

  def timecard_params
    params.require(:timecard).permit(
      :clock_in, :clock_out, :break_minutes, :note
    )
  end

  def generate_csv(timecards)
    CSV.generate(encoding: "UTF-8", force_quotes: true) do |csv|
      csv << ["日付", "ID", "氏名", "出勤", "退勤",
              "休憩(分)", "勤務時間(分)", "備考"]

      timecards.each do |card|
        csv << [
          card.work_date.strftime("%Y/%m/%d"),
          card.employee.employee_code,
          card.employee.name,
          card.clock_in&.strftime("%H:%M"),
          card.clock_out&.strftime("%H:%M"),
          card.break_minutes.to_i,
          card.work_minutes,
          card.note
        ]
      end
    end
  end
end
