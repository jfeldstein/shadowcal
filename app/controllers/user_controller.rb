class UserController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @google_accounts = current_user.google_accounts
    @calendars_by_google_account = @google_accounts.group_by(&:email).map{ |k,a| [k,a.map(&:calendars).flatten.map{|c| [c.summary, [k,c.id].join(":")]}] }
  end
end
