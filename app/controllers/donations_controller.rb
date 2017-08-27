class DonationsController < ApplicationController

  def index
    @purpose = params[:purpose]
    scope    = Donation

    if slug = params[:recipient_slug]
      @recipient ||= Recipient.find_by!(slug: slug)
      scope = scope.where(recipient_id: @recipient.id)
    end

    if purpose = params[:purpose]
      scope = scope.where(purpose: purpose)
    elsif !@recipient
      raise ActiveRecord::RecordNotFound, "parameters missing"
    end

    @donations = scope

    if @donations.empty?
      raise ActiveRecord::RecordNotFound, "empty result"
    end
  end

end
