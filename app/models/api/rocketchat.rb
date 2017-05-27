class Api::Rocketchat
  def initialize(instance = nil)
    unless instance.present?
      provider = Provider.find_by(name: 'rocketchat')
      instance = Instance.find_by(provider_id: provider.id)
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

  def get_channels
    path = '/api/v1/channels.list'
    res = `curl -H "X-Auth-Token: #{@user.token}" \
         -H "X-User-Id: #{@user.key}" \
              https://#{@instance.host}#{path}`
    datum = Datum.find_or_create_by!(
      instance_id: @instance.id,
      path: path,
      method: 'GET',
      req: nil,
    )
    datum.res = res
    datum.save!
    res = JSON.parse(res)
  end
end
