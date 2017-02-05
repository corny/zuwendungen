class DonationsController < ApplicationController

  has_scope :purpose
  has_scope :recipient

  def index
    @purpose   = params[:purpose]
    @recipient = params[:recipient]

    if !params[:recipient] and !params[:purpose]
      raise ActiveRecord::RecordNotFound, "parameters missing"
    end

    @donations = apply_scopes(Donation)

    if @donations.empty?
      raise ActiveRecord::RecordNotFound, "empty result"
    end
  end

end
