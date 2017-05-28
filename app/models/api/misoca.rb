class Api::Misoca < Api
  def initialize
    @api_host   = 'app.misoca.jp'
    @secret_url = 'https://app.misoca.jp/oauth2/applications'
    @auth_path = '/oauth2/authorize'
    @token_path  = '/oauth2/token'
    super
  end

  def contacts
    return @contacts if @contacts
    @contacts = get('/api/v3/contacts', {})
  end
end
