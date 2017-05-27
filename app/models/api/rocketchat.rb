class Api::Rocketchat
  def initialize(instance = nil)
    unless instance.present?
      instance = Instance.find_by(provider_name: 'rocketchat')
    end
    @instance = instance
    @user = User.where(instance_id: instance.id).where.not(token: nil).first
  end

  def login(user, pass)
    # conn = Faraday.new(:url => 'http://deroris.net/') 
    # response = conn.get '/'                 # GET http://www.example.com/users' 
    # return response;

    # raise "hogehoge".inspect

    conn = Faraday.new(:url => "https://#{@instance.host}", :ssl => {:verify => false})
    req2 = conn.get do |req|                           # GET http://sushi.com/search?page=2&limit=100
      req.url '/api/v1/login', :username => user, :password => pass
    end

    return req2;

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

