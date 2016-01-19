require 'spec_helper'

describe Gitlab::LDAP::Authentication, lib: true do
  let(:user)     { create(:omniauth_user, extern_uid: dn) }
  let(:dn)       { 'uid=john,ou=people,dc=example,dc=com' }
  let(:login)    { 'john' }
  let(:password) { 'password' }

  describe 'login' do
    before do
      allow(Gitlab::LDAP::Config).to receive(:enabled?).and_return(true)
    end

    it "finds the user if authentication is successful" do
      expect(user).not_to be_nil

      # try only to fake the LDAP call
      adapter = double('adapter', dn: dn).as_null_object
      allow_any_instance_of(described_class).
        to receive(:adapter).and_return(adapter)

      expect(described_class.login(login, password)).to be_truthy
    end

    it "is false if the user does not exist" do
      # try only to fake the LDAP call
      adapter = double('adapter', dn: dn).as_null_object
      allow_any_instance_of(described_class).
        to receive(:adapter).and_return(adapter)

      expect(described_class.login(login, password)).to be_falsey
    end

    it "is false if authentication fails" do
      expect(user).not_to be_nil

      # try only to fake the LDAP call
      adapter = double('adapter', bind_as: nil).as_null_object
      allow_any_instance_of(described_class).
        to receive(:adapter).and_return(adapter)

      expect(described_class.login(login, password)).to be_falsey
    end

    it "fails if ldap is disabled" do
      allow(Gitlab::LDAP::Config).to receive(:enabled?).and_return(false)
      expect(described_class.login(login, password)).to be_falsey
    end

    it "fails if no login is supplied" do
      expect(described_class.login('', password)).to be_falsey
    end

    it "fails if no password is supplied" do
      expect(described_class.login(login, '')).to be_falsey
    end
  end
end
