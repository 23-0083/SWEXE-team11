
class Timecard < ApplicationRecord
  belongs_to :employee

  validates :work_date, presence: true
  validates :work_date, uniqueness: { scope: :employee_id }
  validates :break_minutes,
            numericality: { greater_than_or_equal_to: 0 }

  # 休憩中かどうか
  def on_break?
    break_started_at.present? && break_until.present?
  end

  # 休憩終了処理
  def finish_break!(now = Time.current)
    return false unless on_break?

    finished_at = [now, break_until].min

    elapsed_seconds = [
      finished_at - break_started_at, 0
    ].max

    minutes = (elapsed_seconds / 60.0).ceil

    update!(
      break_minutes: break_minutes.to_i + minutes,
      break_started_at: nil,
      break_until: nil
    )

    true
  end

  # 勤務時間を分単位で計算
  def work_minutes
    return nil if clock_in.blank? || clock_out.blank?

    total_minutes = ((clock_out - clock_in) / 60).floor

    [total_minutes - break_minutes.to_i, 0].max
  end
end
