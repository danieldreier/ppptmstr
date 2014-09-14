require 'spec_helper'
require 'time'

describe DeployKey do
  describe 'instance methods' do
    describe '#new' do
      before :each do
        @fake_tenant_id = 'rspec-1234-5678-9012'
        @fake_master_uuid = '0123-4567-8901-1234'
        @key1 = DeployKey.new(tenant_id: @fake_tenant_id, master_uuid: @fake_master_uuid, description: 'deploy key created during rspec testing')
        @key2 = DeployKey.new(tenant_id: @fake_tenant_id, master_uuid: @fake_master_uuid, description: 'deploy key created during rspec testing')
      end
      it 'creates a new API key' do
        expect(@key1.key.length).to be > 10
        expect(@key1.description).to eql 'deploy key created during rspec testing'
        expect(@key1.key).not_to eql @key2.key
      end
      it 'sets a recent time for new keys' do
        expect(Time.now.to_i - @key1.creation_date).to be < 5
      end
      it 'generates a different value each time' do
        keys = []
        (1..100).each { keys << DeployKey.new(tenant_id: @fake_tenant_id, master_uuid: @fake_master_uuid).key }
        expect(keys.uniq.count).to eql 100
      end
      it 'raises error if no parameters are specified' do
        expect{DeployKey.new}.to raise_error(ArgumentError)
      end
    end
  end
end
