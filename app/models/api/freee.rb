class Api::Freee < Api
  def initialize
    @token_host = 'secure.freee.co.jp'
    @api_host   = 'api.freee.co.jp'
    @secret_url = 'https://secure.freee.co.jp/oauth/applications'

    super

    @indexes = {
      account_items: {company_id: company_id},
      banks: {},
      companies: {company_id: company_id},
      deals: {company_id: company_id},
      items: {company_id: company_id},
      journals: {company_id: company_id, download_type: 'csv'},
      partners: {company_id: company_id},
      sections: {company_id: company_id},
      tags: {company_id: company_id},
      taxes: {company_id: company_id},
      transfers: {company_id: company_id},
      wallet_txns: {company_id: company_id},
      walletables: {company_id: company_id},
    }
    # TODO: https://secure.freee.co.jp/developers/api/doc/v1.0/selectables/index.html
  end

  def get_all
    @indexes.each do |index, params|
      get("/api/1/#{index}", params)
    end
  end

  def me
    return @me if @me
    @me = get('/api/1/users/me', {companies: true})
  end

  def company_id
    return @company_id if @company_id
    @company_id = me['user']['companies'].first['id']
  end
end
