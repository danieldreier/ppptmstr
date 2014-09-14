require 'rubygems'
require 'bundler/setup'

require 'riak'
require 'hashie'
require 'time'
require 'securerandom'

class Tenant < Hashie::Dash
  property :tenant_id
  property :full_name
  property :email
  property :creation_date, default: Time.new.to_i

  def initialize(hash = {})
    super
    self.tenant_id = SecureRandom.uuid unless self.tenant_id
  end
end

class TenantRepository
  include Hashie::Extensions::SymbolizeKeys
  BUCKET = 'Tenants'

  def initialize(client)
    @client = client
  end

  def save(tenant)
    tenants = @client.bucket(BUCKET)
    key = tenant.tenant_id

    riak_obj = tenants.get_or_new(key)
    riak_obj.data = tenant.to_hash
    riak_obj.content_type = 'application/json'
    riak_obj.store
  end

  def delete(tenant_id:)
    # TODO: deleting a tenant should also delete all their API keys and masters
    riak_obj = @client.bucket(BUCKET)[tenant_id]
    riak_obj.delete
  end

  def get(tenant_id)
    riak_obj = @client.bucket(BUCKET)[tenant_id]

    # symbolized keys is needed because turning the hashie dash into JSON
    # changes :tenant_id (and all other params) into "tenant_id" and then
    # the object can't be created anymore. If you start out using quoted
    # names, hashie doesn't treat them as methods.
    Tenant.new(riak_obj.data.symbolize_keys)
  end
end
