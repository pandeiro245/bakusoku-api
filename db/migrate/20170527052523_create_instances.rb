class CreateInstances < ActiveRecord::Migration[5.1]
  def change
    create_table :instances do |t|
      t.string :provider_name
      t.string :name
      t.string :host
      t.text :memo

      t.timestamps
    end
  end
end
