require 'spec_helper'

describe Tenant do
  describe 'attributes' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:tenant_id) }
    it { is_expected.to respond_to(:full_name) }
  end
  describe 'instance methods' do
    describe '#new' do
      it 'creates a new tenant' do
        tenant = Tenant.new(full_name: 'test user', email: 'test@example.com' )
        tenant2 = Tenant.new(full_name: 'test user', email: 'test@example.com' )

        expect(tenant.email).to eql 'test@example.com'
        expect(tenant.tenant_id.length).to eql 36
        expect(tenant.full_name).to eql 'test user'
        expect(tenant.tenant_id).not_to eql tenant2.tenant_id
      end
    end
  end
end
