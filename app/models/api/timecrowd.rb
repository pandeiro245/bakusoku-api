class Api::Timecrowd < Api
  def initialize
    @api_host   = 'timecrowd.net'
    @secret_url = 'https://timecrowd.net/oauth/applications'
    super
  end

  def me
    return @me if @me
    @me = get('/api/v1/user/info', {})
  end
end
