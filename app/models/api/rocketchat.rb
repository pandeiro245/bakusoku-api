class Api::Rocketchat
  def login(provider, user, pass)
    host = provider.host
    res = `curl https://#{host}/api/v1/login \
         -d "username=#{user}&password=#{pass}"`
    res = JSON.parse(res)
    user = User.find_or_create_by(
      name: user,
      host: host
    )
    user.key = res['data']['userId']
    user.token = res['data']['authToken']
    user.save!
  end
end
