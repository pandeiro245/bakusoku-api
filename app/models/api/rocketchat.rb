class Api::Rocketchat
  def initialize(instance = nil, offline=false)
    @offline = offline
    unless instance.present?
      provider = Provider.find_by(name: 'rocketchat')
      instance = Instance.find_by(provider_id: provider.id)
    end
    @instance = instance
    @user = User.where(instance_id: instance.id).where.not(token: nil).first
  end

  def login(user, pass)
    res = `curl https://#{@instance.host}/api/v1/login \
         -d "username=#{user}&password=#{pass}"`
    res = JSON.parse(res)
    @user = User.find_or_create_by(
      name: user,
      instance_id: @instance.id
    )
    @user.key = res['data']['userId']
    @user.token = res['data']['authToken']
    @user.save!
    @user
  end

  def get_channels
    path = '/api/v1/channels.list'
    datum = Datum.find_or_create_by!(
      instance_id: @instance.id,
      path: path,
      method: 'GET',
      req: nil,
    )
    if @offline
      res = datum.res 
    else
      res = `curl -H "X-Auth-Token: #{@user.token}" \
           -H "X-User-Id: #{@user.key}" \
                https://#{@instance.host}#{path}`
      datum.res = res
      datum.save!
    end
    JSON.parse(res)
  end
end
