require 'riak'
require 'hashie'
require 'time'
require 'securerandom'

class ApiKey < Hashie::Dash
  property :tenant_id, required: true
  property :key, default: SecureRandom.hex(16)
  property :creation_date, default: Time.new.to_i
  property :description
end

class ApiKeyRepository
  include Hashie::Extensions::SymbolizeKeys
  BUCKET = 'ApiKeys'

  def initialize(client)
    @client = client
  end

  def save(api_key)
    # should fail if key already exists; keys can only be created and destroyed
    # to avoid write conflicts. This design should allow the ApiKeys bucket to
    # be safely writable even during cluster splits or partial outages.

    api_keys = @client.bucket(BUCKET)
    key = "#{api_key.tenant_id}-#{api_key.key}"
    raise "key already exists; will not overwrite" if api_keys.exists?(key)

    riak_obj = api_keys.new(key)
    riak_obj.data = api_key.to_hash
    riak_obj.content_type = 'application/json'
    riak_obj.store
  end

  def delete(tenant_id:, api_key_id:)
    riak_obj = @client.bucket(BUCKET)["#{tenant_id}-#{api_key_id}"]
    riak_obj.delete
  end

  def get(tenant_id:, api_key_id:)
    riak_obj = @client.bucket(BUCKET)["#{tenant_id}-#{api_key_id}"]
    ApiKey.new(riak_obj.data.symbolize_keys)
  end
end
