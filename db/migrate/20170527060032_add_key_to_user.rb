class AddKeyToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :key, :string
  end
end
