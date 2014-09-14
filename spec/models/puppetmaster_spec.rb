require 'spec_helper'
require 'time'

describe Puppetmaster do
  describe 'instance methods' do
    describe '#new' do
      before :each do
        @fake_tenant_id = 'rspec-1234-5678-9012'
        @fake_gitrepo   = 'git://git@github.com:puppetlabs/example.git'
        @master1 = Puppetmaster.new(tenant_id: @fake_tenant_id, description: 'master created during rspec testing', gitrepo: @fake_gitrepo, fqdn: 'master1.example.com')
        @master2 = Puppetmaster.new(tenant_id: @fake_tenant_id, description: 'master created during rspec testing', gitrepo: @fake_gitrepo, fqdn: 'master2.example.com')
      end
      it 'sets tenant_id on new master' do
        expect(@master1.tenant_id).to eql @fake_tenant_id
      end
      it 'sets gitrepo on new master' do
        expect(@master1.gitrepo).to eql @fake_gitrepo
      end
      it 'sets a recent time for creation_date' do
        expect(Time.now.to_i - @master1.creation_date).to be < 5
      end
      it 'generates a different uuid each time' do
        keys = []
        (1..100).each { |n| keys << Puppetmaster.new(tenant_id: @fake_tenant_id, description: 'master created during rspec testing', gitrepo: @fake_gitrepo, fqdn: "master#{n}.example.com").uuid }
        expect(keys.uniq.count).to eql 100
      end
      it 'raises error if tenant_id is not specified' do
        expect{Puppetmaster.new(gitrepo: @fake_gitrepo, fqdn: 'master2.example.com')}.to raise_error(ArgumentError)
      end
      it 'raises error if gitrepo is not specified' do
        expect{Puppetmaster.new(tenant_id: @fake_tenant_id, fqdn: 'master2.example.com')}.to raise_error(ArgumentError)
      end
      it 'raises error if fqdn is not specified' do
        expect{Puppetmaster.new(tenant_id: @fake_tenant_id, gitrepo: @fake_gitrepo)}.to raise_error(ArgumentError)
      end
    end
  end
end
