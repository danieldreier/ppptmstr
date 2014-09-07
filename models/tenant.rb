require 'bcrypt'
require 'rubygems'
require 'bundler/setup'

require 'riak'

class Tenant
  include BCrypt

  def initialize(id)
    @TENANT_ID=id.to_s
    @api_keys={}
    @authentication_state=false
    load_api_keys
  end

  def id
    @TENANT_ID
  end

  def authenticated?
    @authentication_state
  end

  def authenticate!(api_key)
    @authentication_state=true if @api_keys[api_key] == true
  end

  def api_keys
    @api_keys
  end

  def authorize_api_key(api_key)
    @api_keys[api_key] = true
    self.save_api_keys
  end

  private

  def load_api_keys
    client = Riak::Client.new
    client.bucket('tenants')
    saved_keys_json = client['tenants'].get(self.id).data
    @api_keys = JSON.parse(saved_keys_json)
  end

  def save_api_keys
    client = Riak::Client.new
    puts client.ping
    client.bucket('tenants')
    kv_tenant = client['tenants'].get_or_new(self.id)
    kv_tenant.data = @api_keys.to_json
    kv_tenant.store
  end

end
