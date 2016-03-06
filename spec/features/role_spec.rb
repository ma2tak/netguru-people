require 'spec_helper'

describe 'Role page', js: true do
  subject { page }

  let!(:role) { create(:role) }
  let!(:user) { create(:user, :admin) }

  before { log_in_as(user) }

  context 'role destroying' do
    let!(:membership) { create(:membership, role: role) }

    before { visit role_path(role) }

    it 'cant delete if there are any memberships associated with this role' do
      expect(page).to have_content(I18n.t('roles.show.destroy_info'))
    end

    it 'links to user profile with that membership' do
      expect(page).to have_content "#{membership.user.decorate.name} , #{membership.project.name}"
    end
  end
end
