require 'spec_helper'

describe 'Project Drepo Sync' do
  let(:project) { create(:project, :public, :repository) }
  let(:path)    { project_path(project) }

  context 'when current user is other users than admin/owner user' do
    before do
      sign_in(create(:user))
      visit path
    end

    it 'has a project title' do
      expect(page).to have_css('.home-panel-title')
    end

    it 'not has a Drepo! link' do
      expect(page).not_to have_link('Drepo!', href: project_new_drepo_sync_path(project))
    end
  end

  context 'check a project page when current user is admin' do
    before do
      sign_in(create(:admin))
      visit path
    end

    it 'has a project title' do
      expect(page).to have_css('.home-panel-title')
    end

    it 'has a Drepo! link for admin/owner user' do
      expect(page).to have_link('Drepo!', href: project_new_drepo_sync_path(project))
    end
  end

  context 'check a Drepo Sync page when current user is admin' do
    let(:path) { project_new_drepo_sync_path(project) }
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
      stub_ipfs_add
      project.create_snapshot(admin)
      visit path
    end

    xit 'project drepo sync page should has ether-wallet unlock section' do
      expect(page).to have_css('.page-title')
      expect(page).to have_content('New Drepo Sync')
    end

    xit 'project drepo sync page should has preview tabs' do
      expect(page).to have_css('.issues-tab')
    end
  end
end
