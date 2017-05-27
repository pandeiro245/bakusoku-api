class Api::Rocketchat
  def initialize(instance = nil)
    unless instance.present?
      instance = Instance.find_by(provider_name: 'rocketchat')
    end
    @instance = instance
    @user = User.where(instance_id: instance.id).where.not(token: nil).first
  end

  def login(user, pass)
    conn = Faraday.new(:url => "https://#{@instance.host}", :ssl => {:verify => false})
    req = conn.post '/api/v1/login', username: user, password: pass
    res = JSON.parse(req.body)
    @user = User.find_or_create_by(
      name: user,
      instance_id: @instance.id
    )
    @user.key = res['data']['userId']
    @user.token = res['data']['authToken']
    @user.save!
    @user
  end

  def channels
    path = '/api/v1/channels.list'
    method = 'GET'
    params = {
      instance_id: @instance.id,
      path: path,
      method: method,
      req: nil,
    }
    datum = Datum.find_by(params)
    unless datum
      res = `curl -H "X-Auth-Token: #{@user.token}" \
           -H "X-User-Id: #{@user.key}" \
                https://#{@instance.host}#{path}`
      params[:res] = res
      datum = Datum.create(params)
    end
    JSON.parse(datum.res)
  end

  def histries
    path = '/api/v1/channels.history'
    method = 'GET'
    channels.each['channels'].each do |channel|
      room_id = channel['_id']
      params = {
        instance_id: @instance.id,
        path: path,
        method: method,
        req: {roomId: room_id}.to_json,
      }
    end
  end
end

