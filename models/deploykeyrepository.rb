require 'riak'
require 'hashie'
require 'time'
require 'securerandom'

class DeployKeyRepository
  include Hashie::Extensions::SymbolizeKeys
  BUCKET = 'DeployKeys'

  def initialize(client)
    @client = client
  end

  def save(deploy_key)
    # should fail if key already exists; keys can only be created and destroyed
    # to avoid write conflicts. This design should allow the ApiKeys bucket to
    # be safely writable even during cluster splits or partial outages.

    deploy_keys = @client.bucket(BUCKET)
    key = "#{deploy_key.tenant_id}-#{deploy_key.uuid}"
    raise "key already exists; will not overwrite" if deploy_keys.exists?(key)

    riak_obj = deploy_keys.new(key)
    riak_obj.data = deploy_key.to_hash
    riak_obj.content_type = 'application/json'
    riak_obj.store
  end

  def delete(tenant_id:, deploy_key_uuid:)
    riak_obj = @client.bucket(BUCKET)["#{tenant_id}-#{deploy_key_uuid}"]
    riak_obj.delete
  end

  def get(tenant_id:, deploy_key_uuid:)
    riak_obj = @client.bucket(BUCKET)["#{tenant_id}-#{deploy_key_uuid}"]
    DeployKey.new(riak_obj.data.symbolize_keys)
  end
end
