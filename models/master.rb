#require 'bcrypt'
require 'rubygems'
require 'bundler/setup'
require 'SecureRandom'

require 'riak'

class Puppetmaster
  attr_accessor :fqdn
  attr_accessor :gitrepo
  attr_accessor :status
  attr_reader   :uuid

  def initialize(uuid: nil, tenant_id:)
    @TENANT_ID = tenant_id.to_s.delete('^0-9')

    if uuid == nil
      @uuid = SecureRandom.uuid
      @fqdn = String.new
      @gitrepo = String.new
      @status = String.new
    else
      @uuid = uuid.to_s.delete('^A-Za-z0-9-')
      load_puppetmaster(@uuid)
      raise "owners do not match" unless @master_definition['tenant_id'] == self.owner
      @fqdn    = @master_definition['fqdn']
      @gitrepo = @master_definition['gitrepo']
      @status  = @master_definition['status']
    end

  end

  def self.list_masters(tenant_id:)
    # this is a horrible way to do it, I just haven't figured out link walking yet
    # TODO: rewrite this using link walking to avoid the performance impact of .keys

    client = Riak::Client.new
    master_bucket="#{tenant_id}-masters"

    masters = []
    client[master_bucket].keys.each do |key|
      begin
        masters << Puppetmaster.new(tenant_id: tenant_id, uuid: key.to_s ).to_hash
      rescue
      end
    end
    masters
  end

  def to_hash
    {
      'tenant_id' => self.owner,
      'uuid'      => self.uuid,
      'fqdn'      => self.fqdn,
      'gitrepo'   => self.gitrepo,
      'status'    => self.status
    }
  end

  def owner
    @TENANT_ID
  end

  def authenticated?
    @authentication_state
  end

  def load_puppetmaster(uuid)
    masters = Riak::Client.new
    master_bucket="#{self.owner}-masters"
    masters.bucket(master_bucket)
    master_json = masters[master_bucket].get(self.uuid).data
    @master_definition = JSON.parse(master_json)
  end

  def save_puppetmaster
    masters = Riak::Client.new
    master_bucket="#{self.owner}-masters"
    masters.bucket(master_bucket)

    kv_master = masters[master_bucket].get_or_new(self.uuid)
    kv_master.data = self.to_hash.to_json
    kv_master.indexes['tenant_id_int'] = [ self.owner.to_i ]
    kv_master.indexes['status_bin'] = [ self.status.to_s ]
    kv_master.indexes['fqdn_bin'] = [ self.fqdn.to_s ]
    kv_master.store

    link_to_tenant
  end

  private

  def link_to_tenant
    # link master to tenant so we can use link-walking to list a tenant's
    # masters efficiently

    client = Riak::Client.new
    tenants_bucket = client['tenants']
    tenant = tenants_bucket.get(self.owner)

    masters_bucket = client["#{self.owner}-masters"]
    master = masters_bucket.get(self.uuid)

    tenant.links << Riak::Link.new("masters", master, "owned")

  end

end
