class Api::Rocketchat
  def initialize(instance = nil)
    instance = Instance.find_by(key: 'rocketchat') unless instance.present?
    @host = instance.host
    @user = User.where(host: @host).where.not(token: nil).first
  end

  def login(user, pass)
    res = `curl https://#{@host}/api/v1/login \
         -d "username=#{user}&password=#{pass}"`
    res = JSON.parse(res)
    @user = User.find_or_create_by(
      name: user,
      host: @host
    )
    @user.key = res['data']['userId']
    @user.token = res['data']['authToken']
    @user.save!
    @user
  end

  def get_channels
    res = `curl -H "X-Auth-Token: #{@user.token}" \
         -H "X-User-Id: #{@user.key}" \
              https://#{@host}/api/v1/channels.list`
    res = JSON.parse(res)
  end
end
