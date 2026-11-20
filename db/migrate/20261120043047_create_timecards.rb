class CreateTimecards < ActiveRecord::Migration[8.1]
  def change
    create_table :timecards do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :work_date
      t.datetime :clock_in
      t.datetime :clock_out
      t.integer :break_minutes
      t.datetime :break_started_at
      t.datetime :break_until
      t.string :note

      t.timestamps
    end
  end
end
