class Api::Freee < Api
  def initialize
    @token_host = 'secure.freee.co.jp'
    @api_host   = 'api.freee.co.jp'
    @secret_url = 'https://secure.freee.co.jp/oauth/applications'
    super
  end

  def me
    get('/api/1/users/me', {companies: true})
  end
end

