class Api::Freee
  def initialize(instance = nil)
    unless instance.present?
      instance = Instance.find_by(provider_name: 'freee')
    end
    @instance = instance

    options = {
      site: "https://#{@instance.host}",
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token'
    }

    @client = OAuth2::Client.new(
      @instance.consumer_key,
      @instance.consumer_secret,
     options) do |conn|
      conn.request :url_encoded
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end
    login
  end

  def me
    @api.get('/api/1/users/me?companies=true').response.env[:body]
  end

  def login
    user = User.find_by(instance_id: @instance.id)
    if user.present?
      token = user.token
    else
      token = get_token
    end

    @api = OAuth2::AccessToken.new(@client, token)
    user = User.find_or_create_by(
      instance_id: @instance.id,
      key:         me['user']['email']
    )
    user.token = token
    user.save!
  end

  def get_token
    url = "https://secure.freee.co.jp/oauth/authorize?client_id=#{@instance.consumer_key}&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code"
    puts("Please access #{url}")
    code = $stdin.gets.chomp
    params = {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => HTTPAuth::Basic.pack_authorization(
          @instance.consumer_key,
          @instance.consumer_secret,
        )
      }
    }
    @client.get_token(params).token
  end
end

