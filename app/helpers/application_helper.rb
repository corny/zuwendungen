module ApplicationHelper

  def title_content(&block)
    content = capture(&block)
    content_for :title, content
    content
  end

  def uniq_states
    @uniq_states ||= Donation.states
  end

end
