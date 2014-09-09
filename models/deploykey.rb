#require 'bcrypt'
# TODO: add creation, update, destruction dates
# TODO: add versioning?

require 'rubygems'
require 'bundler/setup'
require 'SecureRandom'

require 'riak'

class Deploykey
  def initialize(uuid: nil, tenant_id:, master_uuid:, name: nil )
    @deploykey = {}
    @deploykey['tenant_id'] = tenant_id.to_s.delete('^0-9')
    @deploykey['master_uuid'] = master_uuid.to_s.delete('^A-Za-z0-9-')

    if uuid == nil
      @deploykey['uuid'] = SecureRandom.uuid
      @deploykey['name'] = name.to_s
      @deploykey['secret'] = SecureRandom.hex(16)
      @deploykey['creation_date'] = Time.now.rfc2822
    else
      @deploykey['uuid'] = uuid.to_s.delete('^A-Za-z0-9-')
      load_from_db
      raise "owners do not match" unless @deploykey['tenant_id'] == self.tenant_id
    end
  end

  def name
    @deploykey['name'].to_s
  end

  def uuid
    @deploykey['uuid'].to_s
  end

  def tenant_id
    @deploykey['tenant_id']
  end

  def master_uuid
    @deploykey['master_uuid']
  end

  def secret
    @deploykey['secret']
  end

  def self.list_keys(tenant_id:, master_uuid:)
    # this is a horrible way to do it, I just haven't figured out link walking yet
    # TODO: rewrite this using link walking to avoid the performance impact of .keys

    client = Riak::Client.new
    bucket = "#{tenant_id}-#{master_uuid}"

    key_list = []
    client[bucket].keys.each do |key|
      begin
        key_list << Deploykey.new(tenant_id: tenant_id, master_uuid: master_uuid, uuid: key.to_s ).to_hash
      rescue
      end
    end
    key_list
  end

  def to_hash
    @deploykey
  end

  def destroy
    load_from_db
    @deploykey['destruction_date'] = Time.now.rfc2822
    # do some kind of validation
    # submit to queue for destruction
    save_to_db
  end

  def load_from_db

    client = Riak::Client.new
    bucket = "#{self.tenant_id}-#{self.master_uuid}"
    client.bucket(bucket)

    deploykey_json = client[bucket].get(self.uuid).data

    puts deploykey_json
    JSON.parse(deploykey_json)

    @deploykey = JSON.parse(deploykey_json)
  end

  def save_to_db

    client = Riak::Client.new
    bucket = "#{self.tenant_id}-#{self.master_uuid}"

    client.bucket(bucket)

    db_entry = client[bucket].get_or_new(self.uuid)
    db_entry.data = self.to_hash.to_json
    db_entry.indexes['tenant_id_int'] = [ self.tenant_id.to_i ]
    db_entry.indexes['master_bin'] = [ self.master_uuid.to_s ]
    db_entry.store

#    link_to_tenant
  end

  private

  def link_to_tenant
    # link master to tenant so we can use link-walking to list a tenant's
    # masters efficiently
    # TODO: this doesn't seem to work

    client = Riak::Client.new
    tenants_bucket = client['tenants']
    tenant = tenants_bucket.get(self.tenant_id)

    masters_bucket = client["#{self.tenant_id}-masters"]
    master = masters_bucket.get(self.uuid)

    tenant.links << Riak::Link.new("masters", master, "owned")

  end

end
