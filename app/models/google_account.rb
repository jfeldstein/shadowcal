# frozen_string_literal: true

class GoogleAccount < ActiveRecord::Base
  belongs_to :user
  has_many :calendars

  after_create :queue_request_calendars, unless: :skip_callbacks

  after_initialize :refresh_token!, if: :should_refresh_token?

  scope :to_be_refreshed, lambda {
    where(
      "token_expires_at IS NOT NULL AND " \
      "refresh_token IS NOT NULL AND " \
      "token_expires_at < ?", 20.minutes.from_now
    )
  }

  def request_calendars
    GoogleCalendarApiHelper.request_calendars(access_token)
  end

  private

  def queue_request_calendars
    Delayed::Job.enqueue RequestCalendarsJob.new(id), queue: :request_calendars
  end

  def refresh_token!
    resp = GoogleCalendarApiHelper.refresh_access_token(refresh_token)
    update_attributes(
      access_token:     resp["access_token"],
      token_expires_at: resp["expires_in"].to_i.seconds.from_now
    )
  end

  def should_refresh_token?
    return false if skip_callbacks
    token_expires_at < Time.current unless token_expires_at.nil? || refresh_token.blank?
  end
end
