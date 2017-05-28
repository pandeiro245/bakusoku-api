class Api
  def initialize(instance = nil)
    @redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    provider_name = self.class.to_s.split('::').last.downcase
    unless instance.present?
      instance = Instance.find_or_create_by(provider_name: provider_name)
    end
    @instance = instance

    unless @instance.host
      if @api_host
        @instance.host = @api_host
      else
        puts "Please input the consumer_key from #{@secret_url}"
        @instance.host = $stdin.gets.chomp
      end
    end

    unless @instance.consumer_key
      puts "Please input the consumer_key from #{@secret_url}"
      @instance.consumer_key = $stdin.gets.chomp
    end

    unless @instance.consumer_secret
      puts 'Please input the consumer_secret'
      @instance.consumer_secret = $stdin.gets.chomp
    end

    @instance.save!

    options = {
      site: "https://#{@instance.host}",
      authorize_url: @auth_path || '/oauth/authorize',
      token_url: @token_path || '/oauth/token'
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

  def get(path, req={})
    params = {
      instance_id: @instance.id,
      path: path,
      method: 'GET',
      req: req.to_json,
    }

    datum = Datum.find_by(params)

    uri = path
    uri += '?' + req.to_a.map{|i| "#{i.first}=#{i.last}" }.join('&') if req.present?

    unless datum
      params[:res] = @api.get(uri).response.env[:body].to_json
      datum = Datum.create(params)
    end
    JSON.parse(datum.res)
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
      # key:         me['user']['email']
    )
    user.token = token
    user.save!
  end

  def get_token
    @token_host ||= @api_host
    url = "https://#{@token_host}#{@auth_path || '/oauth/authorize'}?client_id=#{@instance.consumer_key}&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=write"
    puts("Please access #{url}")
    code = $stdin.gets.chomp
    params = {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: @redirect_uri,
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

