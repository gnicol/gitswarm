require 'spec_helper'

# EE-specific tests
if PerforceSwarm.ee?
  describe LicenseHelper do
    describe '#license_message' do
      context 'no license installed' do
        before do
          expect(License).to receive(:current).and_return(nil)
        end

        it 'admin user', override: true do
          admin_msg = 'No GitSwarm Enterprise Edition license has been provided yet. Pushing ' \
            'code and creation of issues and merge requests has been disabled. ' \
            'Upload a license in the admin area to activate this functionality.'
          expect(license_message(signed_in: true, is_admin: true)).to eq(admin_msg)
        end

        it 'normal user', override: true do
          user_msg = 'No GitSwarm Enterprise Edition license has been provided yet. ' \
            'Pushing code and creation of issues and merge requests has been disabled. ' \
            'Ask an admin to upload a license to activate this functionality.'
          expect(license_message(signed_in: true, is_admin: false)).to eq(user_msg)
        end
      end
    end
  end
end
