require 'rails_helper'

describe "dashboard", :type => :feature do
  before :each do
    @pair = FactoryGirl.create :sync_pair, last_synced_at: 3.hours.ago
    login_as @pair.user, scope: :user
    visit '/'
  end

  it "shows when a pair is last synced" do
    find('#existing_sync_pairs').should have_content('3 hours ago')

    # And can manually sync a pair
    expect(CalendarShadowHelper).to receive(:cast_from_to) do |from_calendar, to_calendar|
      expect(from_calendar).to eq @pair.from_calendar
      expect(to_calendar).to eq @pair.to_calendar
    end
    click_link('Sync Now')

    # Which updates the last_synced_at
    find('#existing_sync_pairs').should have_content('less than a minute ago')
    @pair.reload
    expect(@pair.last_synced_at).to be_within(5.seconds).of(Time.now)
  end

  it "allows user to add new shadow" do
    page.click_button('Add')
    find('#existing_sync_pairs').find_link('New Shadow')[:href].should eq new_sync_pair_path
  end

  it "allows user to add new google account" do
    page.click_button('Add')
    page.should have_link('Another Google Account')
  end
end
