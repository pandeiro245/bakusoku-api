class CreateProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :host
      t.text :memo
      t.string :key

      t.timestamps
    end
  end
end
