class Instance < ApplicationRecord
  belongs_to :provider
  def initialize

  end

  def login_rc(user, pass)
    Api::Rocketchat.new(self).login(user, pass)
  end
end
