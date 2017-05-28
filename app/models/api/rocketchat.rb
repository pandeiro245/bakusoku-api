class Api::Rocketchat < Api
  def initialize(instance = nil)
    super
  end

  def login
    @user = User.find_by(instance_id: @instance.id)
    unless @user.present?
      puts "Please input username"
      user = $stdin.gets.chomp
      
      puts "Please input password"
      pass = $stdin.gets.chomp

      uri = '/api/v1/login'
      conn = Faraday.new(:url => "https://#{@instance.host}", :ssl => {:verify => false})
      req = conn.post uri, {username: user,
                            password: pass}
      res = JSON.parse(req.body)
      @user.key   = res['data']['userId']
      @user.token = res['data']['authToken']
      @user.save!
    end
    @api = OAuth2::AccessToken.new(@client, @user.token)
  end

  def channels
    get('/api/1/channels.list', {})
  end

  def histries
    channels.each['channels'].each do |channel|
      get('/api/1/channels.history', {})
      room_id = channel['_id']
      params = {
        instance_id: @instance.id,
        path: path,
        method: method,
        req: {roomId: room_id}.to_json,
      }
    end
  end

  def get(path, req)
    method = 'GET'
    conn = Faraday.new(:url => "https://#{@instance.host}/#{path}", :ssl => {:verify => false})
    res = conn.get path, req

    conn = Faraday.new(:url => "https://#{@instance.host}", :ssl => {:verify => false})
    res = conn.post path

    return res

    

    res = JSON.parse(req.body)
    @user = User.find_or_create_by(
      name: user,
      instance_id: @instance.id
    )

    path = '/api/v1/channels.list'
    method = 'GET'
    params = {
      instance_id: @instance.id,
      path: path,
      method: method,
      req: req,
    }
    datum = Datum.find_by(params)
    unless datum
      res = `curl -H "X-Auth-Token: #{@user.token}" \
           -H "X-User-Id: #{@user.key}" \
                https://#{@instance.host}#{path}`
      params[:res] = res

      return res

      datum = Datum.create(params)
    end
    JSON.parse(datum.res)
  end
end

