require 'spec_helper'

describe DeployKeyRepository do
  before :each do
    @fake_tenant_id = 'rspec-1234-5678-9012'
    @bucket = 'DeployKeys'
    @fake_master_uuid = '0123-4567-8901-1234'

  end

  describe 'instance methods' do
    describe '#save' do
      it 'saves the deploy key to Riak' do
        key = DeployKey.new(tenant_id: @fake_tenant_id, master_uuid: @fake_master_uuid)
        client = Riak::Client.new
        deploy_key_repo = DeployKeyRepository.new(client)
        deploy_key_repo.save(key)

        # load from riak
        riak_obj = client.bucket(@bucket)["#{@fake_tenant_id}-#{key.uuid}"]

        expect(riak_obj.data['tenant_id']).to eql @fake_tenant_id
        expect(riak_obj.data['key']).to eql key.key
        riak_obj.delete
      end
    end

    describe '#get' do
      it 'loads a tenant from Riak' do
        key = DeployKey.new(tenant_id: @fake_tenant_id, master_uuid: @fake_master_uuid)
        client = Riak::Client.new
        deploy_key_repo = DeployKeyRepository.new(client)
        deploy_key_repo.save(key)

        # run tested operation
        restored_key = deploy_key_repo.get(tenant_id: @fake_tenant_id, deploy_key_uuid: key.uuid)

        # run tests
        expect(restored_key.tenant_id).to eql @fake_tenant_id
        expect(restored_key.key).to eql key.key

        riak_obj = client.bucket(@bucket)["#{@fake_tenant_id}-#{key.uuid}"]
        riak_obj.delete
      end
    end

    describe '#delete' do
      it 'deletes an API key from Riak' do
        # setup
        key = DeployKey.new(tenant_id: @fake_tenant_id, master_uuid: @fake_master_uuid)
        client = Riak::Client.new
        deploy_key_repo = DeployKeyRepository.new(client)
        deploy_key_repo.save(key)
        deploy_keys = client.bucket(@bucket)

        # run test condition
        expect(deploy_keys.exists?("#{@fake_tenant_id}-#{key.uuid}")).to eql true
        deploy_key_repo.delete(tenant_id: @fake_tenant_id, deploy_key_uuid: key.uuid)
        expect(deploy_keys.exists?("#{@fake_tenant_id}-#{key.uuid}")).to eql false
      end
    end

  end
end
