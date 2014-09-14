#require 'bcrypt'
# TODO: add creation, update, destruction dates
# TODO: add versioning?

require 'securerandom'
require 'riak'

class DeployKey < Hashie::Dash
  property :tenant_id, required: true
  property :master_uuid, required: true
  property :key
  property :uuid
  property :creation_date, default: Time.new.to_i
  property :description
  def initialize(hash = {})
    super
    self.key = SecureRandom.hex(16) unless self.key
    self.uuid = SecureRandom.uuid unless self.uuid
  end
end
