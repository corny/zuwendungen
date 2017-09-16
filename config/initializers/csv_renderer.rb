

ActionController::Renderers.add :csv do |obj, options|

  require 'exporter'

  output = CSV.generate do |csv|
    Exporter.generate(csv, obj)
  end

  send_data output, type: Mime[:csv]
end
