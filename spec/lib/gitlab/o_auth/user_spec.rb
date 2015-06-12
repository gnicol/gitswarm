require 'spec_helper'

describe Gitlab::OAuth::User do
  let(:oauth_user) { Gitlab::OAuth::User.new(auth_hash) }
  let(:gl_user) { oauth_user.gl_user }
  let(:uid) { 'my-uid' }
  let(:provider) { 'my-provider' }
  let(:auth_hash) { double(uid: uid, provider: provider, info: double(info_hash)) }
  let(:info_hash) do
    {
      nickname: '-john+gitlab-ETC%.git@gmail.com',
      name: 'John',
      email: 'john@mail.com'
    }
  end
  let(:ldap_user) { Gitlab::LDAP::Person.new(Net::LDAP::Entry.new, 'ldapmain') }

  describe :persisted? do
    let!(:existing_user) { create(:omniauth_user, extern_uid: 'my-uid', provider: 'my-provider') }

    it "finds an existing user based on uid and provider (facebook)" do
      auth = double(info: double(name: 'John'), uid: 'my-uid', provider: 'my-provider')
      expect( oauth_user.persisted? ).to be_truthy
    end

    it "returns false if use is not found in database" do
      auth_hash.stub(uid: 'non-existing')
      expect( oauth_user.persisted? ).to be_falsey
    end
  end

  describe :save do
    let(:provider) { 'twitter' }

    describe 'signup' do
      shared_examples "to verify compliance with allow_single_sign_on" do
        context "with allow_single_sign_on enabled" do
          before { Gitlab.config.omniauth.stub allow_single_sign_on: true }

          it "creates a user from Omniauth" do
            oauth_user.save

            expect(gl_user).to be_valid
            identity = gl_user.identities.first
            expect(identity.extern_uid).to eql uid
            expect(identity.provider).to eql 'twitter'
          end
        end

        context "with allow_single_sign_on disabled (Default)" do
          before { Gitlab.config.omniauth.stub allow_single_sign_on: false }
          it "throws an error" do
            expect{ oauth_user.save }.to raise_error StandardError
          end
        end
      end

      context "with auto_link_ldap_user disabled (default)" do
        before { Gitlab.config.omniauth.stub auto_link_ldap_user: false }
        include_examples "to verify compliance with allow_single_sign_on"
      end

      context "with auto_link_ldap_user enabled" do
        before { Gitlab.config.omniauth.stub auto_link_ldap_user: true }

        context "and a corresponding LDAP person" do
          before do
            ldap_user.stub(:uid) { uid }
            ldap_user.stub(:username) { uid }
            ldap_user.stub(:email) { ['johndoe@example.com','john2@example.com'] }
            ldap_user.stub(:dn) { 'uid=user1,ou=People,dc=example' }
            allow(oauth_user).to receive(:ldap_person).and_return(ldap_user)
          end

          context "and no account for the LDAP user" do

            it "creates a user with dual LDAP and omniauth identities" do
              oauth_user.save

              expect(gl_user).to be_valid
              expect(gl_user.username).to eql uid
              expect(gl_user.email).to eql 'johndoe@example.com'
              expect(gl_user.identities.length).to eql 2
              identities_as_hash = gl_user.identities.map { |id| { provider: id.provider, extern_uid: id.extern_uid } }
              expect(identities_as_hash).to match_array(
                [ { provider: 'ldapmain', extern_uid: 'uid=user1,ou=People,dc=example' },
                  { provider: 'twitter', extern_uid: uid }
                ])
            end
          end

          context "and LDAP user has an account already" do
            let!(:existing_user) { create(:omniauth_user, email: 'john@example.com', extern_uid: 'uid=user1,ou=People,dc=example', provider: 'ldapmain', username: 'john') }
            it "adds the omniauth identity to the LDAP account" do
              oauth_user.save

              expect(gl_user).to be_valid
              expect(gl_user.username).to eql 'john'
              expect(gl_user.email).to eql 'john@example.com'
              expect(gl_user.identities.length).to eql 2
              identities_as_hash = gl_user.identities.map { |id| { provider: id.provider, extern_uid: id.extern_uid } }
              expect(identities_as_hash).to match_array(
                [ { provider: 'ldapmain', extern_uid: 'uid=user1,ou=People,dc=example' },
                  { provider: 'twitter', extern_uid: uid }
                ])
            end
          end
        end

        context "and no corresponding LDAP person" do
          before { allow(oauth_user).to receive(:ldap_person).and_return(nil) }

          include_examples "to verify compliance with allow_single_sign_on"
        end
      end

    end

    describe 'blocking' do
      let(:provider) { 'twitter' }
      before { Gitlab.config.omniauth.stub allow_single_sign_on: true }

      context 'signup with omniauth only' do
        context 'dont block on create' do
          before { Gitlab.config.omniauth.stub block_auto_created_users: false }

          it do
            oauth_user.save
            expect(gl_user).to be_valid
            expect(gl_user).not_to be_blocked
          end
        end

        context 'block on create' do
          before { Gitlab.config.omniauth.stub block_auto_created_users: true }

          it do
            oauth_user.save
            expect(gl_user).to be_valid
            expect(gl_user).to be_blocked
          end
        end
      end

      context 'signup with linked omniauth and LDAP account' do
        before do
          Gitlab.config.omniauth.stub auto_link_ldap_user: true
          ldap_user.stub(:uid) { uid }
          ldap_user.stub(:username) { uid }
          ldap_user.stub(:email) { ['johndoe@example.com','john2@example.com'] }
          ldap_user.stub(:dn) { 'uid=user1,ou=People,dc=example' }
          allow(oauth_user).to receive(:ldap_person).and_return(ldap_user)
        end

        context "and no account for the LDAP user" do
          context 'dont block on create (LDAP)' do
            before { Gitlab::LDAP::Config.any_instance.stub block_auto_created_users: false }

            it do
              oauth_user.save
              expect(gl_user).to be_valid
              expect(gl_user).not_to be_blocked
            end
          end

          context 'block on create (LDAP)' do
            before { Gitlab::LDAP::Config.any_instance.stub block_auto_created_users: true }

            it do
              oauth_user.save
              expect(gl_user).to be_valid
              expect(gl_user).to be_blocked
            end
          end
        end

        context 'and LDAP user has an account already' do
          let!(:existing_user) { create(:omniauth_user, email: 'john@example.com', extern_uid: 'uid=user1,ou=People,dc=example', provider: 'ldapmain', username: 'john') }

          context 'dont block on create (LDAP)' do
            before { Gitlab::LDAP::Config.any_instance.stub block_auto_created_users: false }

            it do
              oauth_user.save
              expect(gl_user).to be_valid
              expect(gl_user).not_to be_blocked
            end
          end

          context 'block on create (LDAP)' do
            before { Gitlab::LDAP::Config.any_instance.stub block_auto_created_users: true }

            it do
              oauth_user.save
              expect(gl_user).to be_valid
              expect(gl_user).not_to be_blocked
            end
          end
        end
      end


      context 'sign-in' do
        before do
          oauth_user.save
          oauth_user.gl_user.activate
        end

        context 'dont block on create' do
          before { Gitlab.config.omniauth.stub block_auto_created_users: false }

          it do
            oauth_user.save
            expect(gl_user).to be_valid
            expect(gl_user).not_to be_blocked
          end
        end

        context 'block on create' do
          before { Gitlab.config.omniauth.stub block_auto_created_users: true }

          it do
            oauth_user.save
            expect(gl_user).to be_valid
            expect(gl_user).not_to be_blocked
          end
        end

        context 'dont block on create (LDAP)' do
          before { Gitlab::LDAP::Config.any_instance.stub block_auto_created_users: false }

          it do
            oauth_user.save
            expect(gl_user).to be_valid
            expect(gl_user).not_to be_blocked
          end
        end

        context 'block on create (LDAP)' do
          before { Gitlab::LDAP::Config.any_instance.stub block_auto_created_users: true }

          it do
            oauth_user.save
            expect(gl_user).to be_valid
            expect(gl_user).not_to be_blocked
          end
        end
      end
    end
  end
end
