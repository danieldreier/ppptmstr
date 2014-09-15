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
end
