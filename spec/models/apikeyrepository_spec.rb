require 'spec_helper'

describe ApiKeyRepository do
  before :each do
    @fake_tenant_id = 'rspec-1234-5678-9012'
    @bucket = 'ApiKeys'
  end

  describe 'instance methods' do
    describe '#save' do
      it 'saves the api key to Riak' do
        key = ApiKey.new(tenant_id: @fake_tenant_id)
        client = Riak::Client.new
        api_key_repo = ApiKeyRepository.new(client)
        api_key_repo.save(key)

        # load from riak
        riak_obj = client.bucket(@bucket)["#{@fake_tenant_id}-#{key.key}"]

        expect(riak_obj.data['tenant_id']).to eql @fake_tenant_id
        expect(riak_obj.data['key']).to eql key.key
        riak_obj.delete
      end
    end

    describe '#get' do
      it 'loads a tenant from Riak' do
        key = ApiKey.new(tenant_id: @fake_tenant_id)
        client = Riak::Client.new
        api_key_repo = ApiKeyRepository.new(client)
        api_key_repo.save(key)

        # run tested operation
        restored_key = api_key_repo.get(tenant_id: @fake_tenant_id, api_key_id: key.key)

        # run tests
        expect(restored_key.tenant_id).to eql @fake_tenant_id
        expect(restored_key.key).to eql key.key

        riak_obj = client.bucket(@bucket)["#{@fake_tenant_id}-#{key.key}"]
        riak_obj.delete
      end
    end

    describe '#delete' do
      it 'deletes an API key from Riak' do
        # setup
        key = ApiKey.new(tenant_id: @fake_tenant_id)
        client = Riak::Client.new
        api_key_repo = ApiKeyRepository.new(client)
        api_key_repo.save(key)
        api_keys = client.bucket(@bucket)

        # run test condition
        expect(api_keys.exists?("#{@fake_tenant_id}-#{key.key}")).to eql true
        api_key_repo.delete(tenant_id: @fake_tenant_id, api_key_id: key.key)
        expect(api_keys.exists?("#{@fake_tenant_id}-#{key.key}")).to eql false
      end
    end

  end
end
