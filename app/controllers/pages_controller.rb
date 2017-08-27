class PagesController < ApplicationController

  def state
    @donations = Donation.where(state: params[:id]).grouped_by_recipients.joins(:recipient).order("amount DESC").limit(50)
  end

end
