class CreateDonations < ActiveRecord::Migration[5.0]
  def change
    create_table :donations do |t|
      t.date    :date_begin, null: false
      t.date    :date_end,   null: false
      t.string  :state,      null: false
      t.string  :number
      t.string  :donor,      null: false, index: true
      t.string  :recipient,  null: false, index: true
      t.string  :kind,       null: false
      t.string  :purpose,    null: false
      t.decimal :amount,     null: false, precision: 13, scale: 2
    end

    add_index :donations, [:date_begin, :date_end, :state]
    add_index :donations, [:state, :number], unique: true
  end
end
