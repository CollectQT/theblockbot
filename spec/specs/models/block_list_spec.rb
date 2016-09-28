describe "BlockList", :type => :feature  do

  let(:block_list) {
    BlockList.find_or_create_by(name: 'testing12')
  }
  let(:block_list_private) {
    BlockList.find_or_create_by(name: '!private list!', private_list: true)
  }

  it 'allows viewing the show page' do
    visit block_list_path(block_list)
    expect(page).to have_content(block_list.name)
  end

  context 'private_list' do
    it 'denies view by not logged in user' do
      visit block_list_path(block_list_private)
      expect(page).to have_content('Not authorized')
    end

    it 'denies view to generic user' do
      mock_user_twitter

      visit block_list_path(block_list_private)
      expect(page).to have_content('Not authorized')
    end

    it 'allows view by Blocker' do
      mock_user_twitter
      user = User.find_by(name: 'Twitter')

      blocker = Blocker.find_or_create_by(
        block_list: block_list_private,
        user: user,
      )

      visit block_list_path(block_list_private)
      expect(page).to have_content(block_list_private.name)
      expect(page).to have_content(user.name)

      blocker.delete
    end

    it 'allows view by Admin' do
      mock_user_twitter
      user = User.find_by(name: 'Twitter')

      admin = Admin.find_or_create_by(
        block_list: block_list_private,
        user: user,
      )

      visit block_list_path(block_list_private)
      expect(page).to have_content(block_list_private.name)
      expect(page).to have_content(user.name)

      admin.delete
    end
  end

end
