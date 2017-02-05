module Source
  class Hamburg < Base

    def urls
      [
        # Beginn 2010
        "https://www.hamburg.de/contentblob/4292692/1463ba5948cc4ba386b5bbca417abd73/data/zuwendungsbericht-2011.xlsx",
        # Beginn 2012
        "http://www.hamburg.de/contentblob/4284536/data/zuwendungsbericht-2013.xlsx"
      ]
    end

    def import(path)
      sheet = SimpleSpreadsheet::Workbook.read(path)
      line  = 1

      # skip trailing lines
      until sheet.cell(line,1)
        line += 1
      end

      # map column names to column numbers
      columns = sheet.first_column.upto(sheet.last_column).map do |i|
        text = sheet.cell(2,i)
        text = Nokogiri::HTML(sheet.cell(2,8)).text if text.starts_with?("<html>")
        [
          text.match(/^[[:alpha:]\. -]+/)[0].strip,
          i,
        ]
      end.to_h

      # iterate over data rows
      (line+1).upto(sheet.last_row).each do |line|
        update_donation(
          number:     sheet.cell(line, columns['INEZ-Nummer']),
          recipient:  sheet.cell(line, columns['Zuwendungsempfänger']),
          donor:      sheet.cell(line, columns['Behörde']),
          purpose:    sheet.cell(line, columns['Zuwendung für']),
          date_begin: sheet.cell(line, columns['Zeitraum Von']),
          date_end:   sheet.cell(line, columns['Zeitraum Bis']),
          amount:     sheet.cell(line, columns['Gesamtzuwendung']),
          kind:       sheet.cell(line, columns['Förderungsart']),
        )
      end
    end

  end
end
