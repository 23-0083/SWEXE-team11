
class PunchesController < ApplicationController
  before_action :authenticate_employee, only: [:create]

  def index
    finish_expired_breaks
    load_today_timecards
  end

  def status
    finish_expired_breaks
    load_today_timecards

    render partial: "status_table", layout: false
  end

  def create
    case params[:action_type]
    when "clock_in"
      clock_in
    when "clock_out"
      clock_out
    when "break_start"
      break_start
    when "break_end"
      break_end
    else
      redirect_to root_path, alert: "不正な操作です"
    end
  end

  private

  # スタッフIDとPINによる本人確認
  def authenticate_employee
    @employee = Employee.find_by(
      employee_code: params[:employee_code].to_s
    )

    unless @employee&.authenticate(params[:pin].to_s)
      redirect_to root_path,
                  alert: "スタッフIDまたはPINが正しくありません"
      return
    end
  end

  # 本日の勤務記録を取得
  def load_today_timecards
    @timecards = Timecard.includes(:employee)
                         .where(work_date: Date.current)
                         .order("employees.employee_code")
                         .references(:employee)
  end

  # 予定時刻を過ぎた休憩を自動確定
  def finish_expired_breaks
    Timecard.where(clock_out: nil)
            .where("break_until <= ?", Time.current)
            .find_each do |card|
      card.with_lock do
        card.finish_break! if card.on_break? &&
                              card.break_until <= Time.current
      end
    end
  end

  # 出勤
  def clock_in
    card = @employee.timecards.find_or_initialize_by(
      work_date: Date.current
    )

    if card.persisted?
      redirect_to root_path,
                  alert: "本日はすでに出勤済みです"
      return
    end

    card.update!(
      clock_in: Time.current,
      break_minutes: 0
    )

    redirect_to root_path,
                notice: "#{@employee.name}さんの出勤を記録しました"
  end

  # 退勤
  def clock_out
    card = today_card
    return unless card

    if card.clock_out.present?
      redirect_to root_path,
                  alert: "すでに退勤済みです"
      return
    end

    card.with_lock do
      card.finish_break! if card.on_break?
      card.update!(clock_out: Time.current)
    end

    redirect_to root_path,
                notice: "#{@employee.name}さんの退勤を記録しました"
  end

  # 休憩開始
  def break_start
    card = today_card
    return unless card

    minutes = params[:break_minutes].to_i

    unless [5, 15, 30, 45, 60].include?(minutes)
      redirect_to root_path,
                  alert: "休憩時間が不正です"
      return
    end

    error_message = nil

    card.with_lock do
      if card.clock_out.present?
        error_message = "退勤後は休憩できません"
      else
        # 以前の休憩が終了済みなら確定
        if card.on_break? &&
           card.break_until <= Time.current
          card.finish_break!
        end

        if card.on_break?
          error_message = "すでに休憩中です"
        else
          now = Time.current

          card.update!(
            break_started_at: now,
            break_until: now + minutes.minutes
          )
        end
      end
    end

    if error_message
      redirect_to root_path, alert: error_message
    else
      redirect_to root_path,
                  notice: "#{@employee.name}さんの休憩を開始しました"
    end
  end

  # 休憩を早期終了
  def break_end
    card = today_card
    return unless card

    finished = false

    card.with_lock do
      if card.clock_out.blank? && card.on_break?
        card.finish_break!
        finished = true
      end
    end

    if finished
      redirect_to root_path,
                  notice: "#{@employee.name}さんの休憩を終了しました"
    else
      redirect_to root_path,
                  alert: "現在休憩中ではありません"
    end
  end

  # 本日の勤務記録を取得
  def today_card
    card = @employee.timecards.find_by(
      work_date: Date.current
    )

    unless card
      redirect_to root_path,
                  alert: "先に出勤してください"
    end

    card
  end
end
