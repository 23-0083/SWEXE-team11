class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :employee_code
      t.string :name
      t.string :pin_digest

      t.timestamps
    end
  end
end
