# frozen_string_literal: true

class RemoveNilasTokenFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :nilas_token, :text
  end
end
