class Provider < ApplicationRecord
  def login_rc(user, pass)
    Api::Rocketchat.new.login(self, user, pass)
  end
end
