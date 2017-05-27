class AddConsumerKeyAndConsumerSecretToInstance < ActiveRecord::Migration[5.1]
  def change
    add_column :instances, :consumer_key, :string
    add_column :instances, :consumer_secret, :string
  end
end
