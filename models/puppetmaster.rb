#require 'bcrypt'
# TODO: add creation, update, destruction dates
# TODO: add versioning?

require 'rubygems'
require 'bundler/setup'
require 'securerandom'
require 'hashie'
require 'riak'


class Puppetmaster < Hashie::Dash
  property :fqdn, required: true
  property :gitrepo, required: true
  property :tenant_id, required: true
  property :uuid
  property :description
  property :creation_date, default: Time.new.to_i

  def initialize(hash = {})
    super
    self.uuid = SecureRandom.uuid unless self.uuid
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

  def deploy
    # check if this has been deployed before or is new
    # load_puppetmaster(self.uuid)
    # do some kind of validation
    # submit to queue for creation
    self.status = 'pending_provisioning'
#    save_puppetmaster
  end

  def destroy
    load_puppetmaster(self.uuid)
    # do some kind of validation
    # submit to queue for destruction
    self.status = 'terminating'
#    save_puppetmaster
  end
end
