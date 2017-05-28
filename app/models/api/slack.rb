class Api::Slack < Api
  def initialize
    @api_host    = 'slack.com'
    @secret_url  = 'https://slack.com/'
    @auth_path   = '/api/oauth.access'
    @token_path  = '/oauth2/token'
    super
  end

  def oauth_access
    return @oauth_access if @oauth_access
    @oauth_access = get('/api/oauth.access', {})
  end
end


# Client ID
# 85077791542.188381086896
# Client Secret
# 79c137a74fab7d42b559a4c924d67891

#xoxp-85077791542-85083667541-189872707351-3127cdfe61a8e0fec90af8c37abc3bbf
# class Api::Slack
#   def initialize(instance = nil)
#     provider_name = self.class.to_s.split('::').last.downcase
#     unless instance.present?
#       instance = Instance.find_or_create_by(provider_name: provider_name)
#     end
#     @instance = instance
#     @instance.save!

#     @user = User.where(instance_id: instance.id).where.not(token: nil).first
#     @site = "https://#{@instance.host}"
#   end

# end

