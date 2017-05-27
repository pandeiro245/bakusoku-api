class CreateProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :host
      t.text :memo

      t.timestamps
    end
  end
end
