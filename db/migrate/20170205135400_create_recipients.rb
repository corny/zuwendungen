class CreateRecipients < ActiveRecord::Migration[5.1]
  def change
    create_table :recipients do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
    add_index :recipients, :name, unique: true
    add_index :recipients, :slug, unique: true
  end
end
