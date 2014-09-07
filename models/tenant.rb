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
    @authentication_state=true if self.validate_api_key(api_key)
  end

  def api_keys
    @api_keys
  end

  def hash_api_key(api_key)
    BCrypt::Password.create(api_key)
  end

  def validate_api_key(api_key)
    validation_successful=false
    @api_keys.each do |key_hash, enabled|
      if enabled == true
        begin
          hash=BCrypt::Password.new(key_hash)
        rescue BCrypt::Errors::InvalidHash
        end
        validation_successful=true if hash == api_key
      end
    end
    validation_successful
  end

  def authorize_api_key(api_key)
    hashed_api_key = hash_api_key(api_key)
    @api_keys[hashed_api_key] = true
    save_api_keys
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
    client.bucket('tenants')
    kv_tenant = client['tenants'].get_or_new(self.id)
    kv_tenant.data = @api_keys.to_json
    kv_tenant.store
  end

end
