class Provider < ApplicationRecord
  def login_rc(user, pass)
    Api::Rocketchat.new(self).login(user, pass)
  end
end
