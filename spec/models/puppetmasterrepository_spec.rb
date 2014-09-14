require 'spec_helper'

describe PuppetmasterRepository do
  before :each do
    @fake_tenant_id = 'rspec-1234-5678-9012'
    @bucket         = 'Puppetmasters'
    @fake_gitrepo   = 'git://git@github.com:puppetlabs/example.git'
  end

  describe 'instance methods' do
    describe '#save' do
      it 'saves puppetmaster to Riak' do
        master = Puppetmaster.new(tenant_id: @fake_tenant_id, description: 'master created during rspec testing', gitrepo: @fake_gitrepo, fqdn: 'master1.example.com')
        client = Riak::Client.new
        puppetmaster_repo = PuppetmasterRepository.new(client)
        puppetmaster_repo.save(master)

        # load from riak
        riak_obj = client.bucket(@bucket)["#{@fake_tenant_id}-#{master.uuid}"]

        expect(riak_obj.data['tenant_id']).to eql @fake_tenant_id
        expect(riak_obj.data['fqdn']).to eql 'master1.example.com'
        expect(riak_obj.data['gitrepo']).to eql @fake_gitrepo

        # clean up
        riak_obj.delete
      end
    end

    describe '#get' do
      it 'loads a puppetmaster from Riak' do
        # setup
        master = Puppetmaster.new(tenant_id: @fake_tenant_id, description: 'master created during rspec testing', gitrepo: @fake_gitrepo, fqdn: 'master1.example.com')
        client = Riak::Client.new
        puppetmaster_repo = PuppetmasterRepository.new(client)
        puppetmaster_repo.save(master)

        # run tested operation
        restored_master = puppetmaster_repo.get(tenant_id: @fake_tenant_id, puppetmaster_uuid: master.uuid)

        # run tests
        expect(restored_master.tenant_id).to eql @fake_tenant_id
        expect(restored_master.uuid).to eql master.uuid
        expect(restored_master.gitrepo).to eql @fake_gitrepo

        # clean up
        riak_obj = client.bucket(@bucket)["#{@fake_tenant_id}-#{master.uuid}"]
        riak_obj.delete
      end
    end

    describe '#delete' do
      it 'deletes a puppetmaster record from Riak' do
        # setup
        master = Puppetmaster.new(tenant_id: @fake_tenant_id, description: 'master created during rspec testing', gitrepo: @fake_gitrepo, fqdn: 'master1.example.com')
        client = Riak::Client.new
        puppetmaster_repo = PuppetmasterRepository.new(client)
        puppetmaster_repo.save(master)
        puppetmasters = client.bucket(@bucket)

        # run test condition
        expect(puppetmasters.exists?("#{@fake_tenant_id}-#{master.uuid}")).to eql true
        puppetmaster_repo.delete(tenant_id: @fake_tenant_id, puppetmaster_uuid: master.uuid)
        expect(puppetmasters.exists?("#{@fake_tenant_id}-#{master.uuid}")).to eql false
      end
    end

  end
end
