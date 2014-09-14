require 'spec_helper'
require 'time'

describe ApiKey do
  describe 'instance methods' do
    describe '#new' do
      before :each do
        @fake_tenant_id = 'rspec-1234-5678-9012'
        @key1 = ApiKey.new(tenant_id: @fake_tenant_id, description: 'API key created during rspec testing')
        @key2 = ApiKey.new(tenant_id: @fake_tenant_id, description: 'API key created during rspec testing')
      end
      it 'creates a new API key' do
        expect(@key1.key.length).to be > 10
        expect(@key1.description).to eql 'API key created during rspec testing'
        expect(@key1.key).not_to eql @key2.key
      end
      it 'sets a recent time for new keys' do
        expect(Time.now.to_i - @key1.creation_date).to be < 5
      end
      it 'generates a different value each time' do
        keys = []
        (1..100).each { keys << ApiKey.new(tenant_id: @fake_tenant_id).key }
        expect(keys.uniq.count).to eql 100
      end
      it 'raises error if tenant_id is not specified' do
        expect{ApiKey.new}.to raise_error(ArgumentError)
      end
    end
  end
end
