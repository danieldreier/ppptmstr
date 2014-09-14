#require 'bcrypt'
# TODO: add creation, update, destruction dates
# TODO: add versioning?

require 'rubygems'
require 'bundler/setup'
require 'securerandom'
require 'hashie'
require 'riak'

class PuppetmasterRepository
  include Hashie::Extensions::SymbolizeKeys
  BUCKET = 'Puppetmasters'

  def initialize(client)
    @client = client
  end

  def save(puppetmaster)
    # should fail if a master already exists; masters can only be created and destroyed
    # to avoid write conflicts. This design should allow the puppetmasters bucket to
    # be safely writable even during cluster splits or partial outages.

    puppetmasters = @client.bucket(BUCKET)
    key = "#{puppetmaster.tenant_id}-#{puppetmaster.uuid}"
    raise "puppetmaster already exists; will not overwrite" if puppetmasters.exists?(key)

    riak_obj = puppetmasters.new(key)
    riak_obj.data = puppetmaster.to_hash
    riak_obj.content_type = 'application/json'
    riak_obj.store
  end

  def delete(tenant_id:, puppetmaster_uuid:)
    # TODO: this should probably also trigger some kind of cleanup to actually
    # de-provision the master
    # TODO: deleting in riak is non-trivial (http://basho.com/riaks-config-behaviors-part-3/)
    # so perhaps this should be redesigned (create a disabled node entry somewhere?)
    riak_obj = @client.bucket(BUCKET)["#{tenant_id}-#{puppetmaster_uuid}"]
    riak_obj.delete
  end

  def get(tenant_id:, puppetmaster_uuid:)
    riak_obj = @client.bucket(BUCKET)["#{tenant_id}-#{puppetmaster_uuid}"]
    Puppetmaster.new(riak_obj.data.symbolize_keys)
  end
end
