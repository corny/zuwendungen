module Source
  class Berlin < Base

    def urls
      # XLS files are broken. ruby-ole-1.2.12 fails with:
      # Ole::Storage::FormatError: OLE2 signature is invalid
      (2010..2016).map do |year|
        [
          "#{year}.html",
          "https://www.berlin.de/sen/finanzen/service/zuwendungsdatenbank/index.php/index/print.html?q&jahr=#{year}",
        ]
      end.to_h
    end

    def import(path)
      html = Nokogiri::HTML(path.read)
      rows = html.at("tbody").elements

      (0...(rows.size)).step(2).each do |i|
        data = (rows[i].elements + rows[i+1].elements).map{|e| [e['headers'], e.text] }.to_h

        update_donation(
          number:     "#{data['Jahr']}-#{i/2}",
          date_begin: "#{data['Jahr']}-01-01",
          date_end:   "#{data['Jahr']}-12-31",
          recipient:  data['Name'],
          donor:      data['Geber'],
          purpose:    data['Zweck'],
          amount:     data['Betrag'],
          kind:       data['Art'],
        )
      end
    end

  end
end
