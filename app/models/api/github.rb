class Api::Github < Api
  def initialize
    @api_host   = 'api.github.com'
    @secret_url = 'https://github.com/settings/developers'
    # @auth_path = '/oauth2/authorize'
    # @token_path  = '/oauth2/token'
    super
  end

  def me
    return @me if @me
    @me = get('/api/v3/user', {})
  end
end

