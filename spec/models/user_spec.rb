# frozen_string_literal: true

require "rails_helper"

describe "User", type: :model do
  let(:user) { FactoryBot.create :user }

  describe "#add_or_update_google_account" do
    before :each do
      allow(GoogleCalendarApiHelper)
        .to receive(:request_calendars)
        .and_return([])

      expect(user.google_accounts.count).to eq 0 # sanity

      user.add_or_update_google_account(Faker::Omniauth.unique.google.to_ostruct)
    end

    it "adds a new google account" do
      expect(user.google_accounts.count).to eq 1
    end

    it "adds a second google account" do
      user.add_or_update_google_account(Faker::Omniauth.unique.google.to_ostruct)
      expect(user.google_accounts.count).to eq 2
    end

    context "without expires_at" do
      context "with refresh_token" do
        it "defaults expiry to 40 minutes" do
          auth_without_expires_at = Faker::Omniauth.unique.google.to_ostruct
          auth_without_expires_at.credentials.refresh_token = 'abc123'
          auth_without_expires_at.credentials.expires_at = nil
          user.add_or_update_google_account(auth_without_expires_at)
          expect(user.google_accounts.last.token_expires_at).to be_within(1.second).of(40.minutes.from_now)
        end
      end

      context "without refresh_token" do
        it "leaves expires_at nil" do
          auth_without_expires_at = Faker::Omniauth.unique.google.to_ostruct
          auth_without_expires_at.credentials.expires_at = nil
          auth_without_expires_at.credentials.refresh_token = nil
          user.add_or_update_google_account(auth_without_expires_at)
          expect(user.google_accounts.last.token_expires_at).to be_nil
        end
      end
    end

    it "records refresh_token" do
      expect(user.google_accounts.first.refresh_token).to_not be_nil
    end
  end
end
