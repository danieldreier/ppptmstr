require 'spec_helper'
BUCKET = 'Tenants'

describe TenantRepository do
  describe 'instance methods' do
    describe '#save' do
      it 'saves the tenant to Riak' do
        tenant = Tenant.new(full_name: 'save test user', email: 'test@example.com' )
        client = Riak::Client.new
        tenant_repo = TenantRepository.new(client)
        tenant_repo.save(tenant)

        # load from riak
        riak_obj = client.bucket(BUCKET)[tenant.tenant_id]
        riak_obj.data['tenant_id']

        expect(riak_obj.data['tenant_id']).to eql tenant.tenant_id
        expect(riak_obj.data['full_name']).to eql 'save test user'
        expect(riak_obj.data['email']).to eql 'test@example.com'
        riak_obj.delete
      end
    end

    describe '#get' do
      it 'loads a tenant from Riak' do
        tenant = Tenant.new(full_name: 'get test user', email: 'test@example.com' )
        client = Riak::Client.new
        tenant_repo = TenantRepository.new(client)
        tenant_repo.save(tenant)

        # load from riak
        restored_tenant = tenant_repo.get(tenant.tenant_id)

        # run tests
        expect(restored_tenant.email).to eql 'test@example.com'
        expect(restored_tenant.tenant_id).to eql tenant.tenant_id
        expect(restored_tenant.full_name).to eql 'get test user'

        # clean up
        riak_obj = client.bucket(BUCKET)[tenant.tenant_id]
        riak_obj.delete
      end
    end

    describe '#delete' do
      it 'deletes a tenant from Riak' do
        # setup
        tenant = Tenant.new(full_name: 'get test user', email: 'test@example.com' )
        client = Riak::Client.new
        tenant_repo = TenantRepository.new(client)
        tenant_repo.save(tenant)
        tenant_keys = client.bucket(BUCKET)
        key = tenant.tenant_id

        # run test condition
        expect(tenant_keys.exists?(key)).to eql true
        tenant_repo.delete(tenant_id: tenant.tenant_id)
        expect(tenant_keys.exists?(key)).to eql false
      end
    end



  end
end
