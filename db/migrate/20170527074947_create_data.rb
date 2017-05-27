class CreateData < ActiveRecord::Migration[5.1]
  def change
    create_table :data do |t|
      t.references :instance, foreign_key: true
      t.string :path
      t.string :method
      t.text :req
      t.text :res

      t.timestamps
    end
  end
end
