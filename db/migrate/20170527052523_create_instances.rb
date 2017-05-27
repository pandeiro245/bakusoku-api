class CreateInstances < ActiveRecord::Migration[5.1]
  def change
    create_table :instances do |t|
      t.string :name
      t.string :host
      t.text :memo
      t.references :provider, foreign_key: true

      t.timestamps
    end
  end
end
