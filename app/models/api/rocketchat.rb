class Api::Rocketchat
  def initialize(instance = nil)
    provider_name = self.class.to_s.split('::').last.downcase
    unless instance.present?
      instance = Instance.find_or_create_by(provider_name: provider_name)
    end
    @instance = instance
    @instance.save!

    @user = User.where(instance_id: instance.id).where.not(token: nil).first
    @site = "https://#{@instance.host}"
  end

  # rocketchar login
  def login(user, pass)
    path = '/api/v1/login'
    # TODO: delete verify => false
    conn = Faraday.new(:url => @site, :ssl => {:verify => false})
    req = conn.post path, {username: user,
                          password: pass}
    res = JSON.parse(req.body)

    @user = User.find_or_create_by(
      name:        user,
      instance_id: @instance.id
    )
    @user.key   = res['data']['userId']
    @user.token = res['data']['authToken']
    @user.save!
    @user
  end

  # get channles list
  def channels
    path = '/api/v1/channels.list'
    # TODO: delete verify => false
    conn = Faraday.new(:url => @site, :ssl => {:verify => false})

    res = conn.get do |req|
      req.url(path)
      req.headers = {'Content-Type' => 'application/json',
                     'X-Auth-Token' => @user.token,
                     'X-User-Id'    => @user.key
                    }
    end
    return JSON.parse(res.body)
  end

  def histries

    path = '/api/v1/channels.history'
    # TODO: delete verify => false
    conn = Faraday.new(:url => @site, :ssl => {:verify => false})

    histries = []

    self.channels()['channels'].each do |c|
      res = conn.get do |req|
        req.url(path)
        req.headers = {'Content-Type' => 'application/json',
                       'X-Auth-Token' => @user.token,
                       'X-User-Id'    => @user.key
                      }
        req.params['roomId'] = c['_id']
      end

      histries.push(JSON.parse(res.body))
    end
    return histries
  end
end

