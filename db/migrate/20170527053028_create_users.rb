class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.references :instance, foreign_key: true
      t.string :key
      t.string :name
      t.string :token

      t.timestamps
    end
  end
end
