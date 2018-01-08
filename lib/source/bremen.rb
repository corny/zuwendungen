module Source
  class Bremen < Base

    KINDS = {
      "A"  => "Anteilfinanzierung",
      "F"  => "Fehlbedarfsfinanzierung",
      "FB" => "Festbetragsfinanzierung",
      "V"  => "Vollfinanzierung",
      ""   => "keine Angabe",
    }

    def urls
      {
        "2009-2010.xls"  => "http://transparenz.bremen.de/sixcms/media.php/bremen02.a.13.de/download/Zuwendungsempf%E4nger_2009-2010.xls",
        "2011.xlsx"      => "http://transparenz.bremen.de/sixcms/media.php/13/Zuwendungen_2011_2012.xlsx",
        "2012-2013.xlsx" => "https://ssl5.bremen.de/transparenzportal/sixcms/media.php/13/OpenData_Zuwendungsbericht%202013.xlsx",
        "2014-2015.xlsx" => "https://ssl5.bremen.de/transparenzportal/sixcms/media.php/13/2016-07-12_Zuwendungsbericht_2015_OpenData.xlsx",
        "2017.xlsx"      => "https://www.finanzen.bremen.de/sixcms/media.php/13/Zuwendungen%2B3.%2BQuartalsbericht%2B2017.xlsx",
      }
    end

    def import(path)
      sheet = SimpleSpreadsheet::Workbook.read(path)
      years = File.basename(path).scan(/\d+/).map(&:to_i)

      if years[0] >= 2017
        import_2017(sheet)
      elsif years[0] >= 2014
        import_2014(sheet)
      elsif years[0] >= 2011
        import_2011(sheet, years)
      elsif years[0] >= 2009
        import_2009(sheet, years)
      else
        raise ArgumentError, "unsupported data"
      end
    end

    def import_2009(sheet, years)
      # map column names to column numbers
      columns = sheet.first_column.upto(sheet.last_column).map do |i|
        if text = sheet.cell(2,i)
          [text, i ]
        end
      end.compact.to_h


      # iterate over data rows
      4.upto(sheet.last_row).each do |line|
        zweck = sheet.cell(line, columns['Zuwendungszweck bzw. Art der Leistungen'])
        next unless zweck

        years.each_with_index do |year,i|
          amount = [
            sheet.cell(line, columns['institutionelle Zuwendungen Bremens']+i),
            sheet.cell(line, columns['Projektförderungen Bremens']+i),
          ].map(&:presence).compact.sum

          if amount != 0
            update_donation(
              number:     "#{year}-#{line}",
              recipient:  sheet.cell(line, columns['Zuwendungsempfänger']),
              purpose:    sheet.cell(line, columns['Zuwendungszweck bzw. Art der Leistungen']),
              date_begin: "#{year}-01-01",
              date_end:   "#{year}-12-31",
              amount:     amount,
              donor:      "keine Angabe",
              kind:       "keine Angabe",
            )
          end
        end
      end
    end

    def import_2011(sheet, years)
      # map column names to column numbers
      columns = sheet.first_column.upto(sheet.last_column).map{|i| [sheet.cell(1,i), i] }.to_h

      year_fields = years.map do |year|
        [year, [
          "institutionelle Zuwendungen Bremens #{year}",
          "Projektförderungen Bremens #{year}",
          "Institutionelle Förderungen/Projektförderungen Dritter (z.B. Bund, EU) #{year}",
        ]]
      end.to_h

      # iterate over data rows
      2.upto(sheet.last_row).each do |line|
        year_fields.each do |year,fields|
          amount = fields.map{|col| sheet.cell(line, columns[col]) }.compact.sum
          next if amount == 0

          update_donation(
            number:     "#{year}-#{line}",
            recipient:  sheet.cell(line, columns['Zuwendungsempfänger']),
            donor:      sheet.cell(line, columns['Ressort']),
            purpose:    sheet.cell(line, columns['Zuwendungszweck bzw. Art der Leistungen']),
            date_begin: "#{year}-01-01",
            date_end:   "#{year}-12-31",
            amount:     amount,
            kind:       KINDS[sheet.cell(line, columns['Finan-zierungs-art'])].to_s,
          )
        end
      end
    end

    def import_2014(sheet)
      # map column names to column numbers
      columns = sheet.first_column.upto(sheet.last_column).map do |i|
        if text = sheet.cell(1,i)
          [
            text.gsub(/-?\n/,"").strip,
            i,
          ]
        end
      end.compact.to_h

      years = [sheet.cell(2, 5), sheet.cell(2, 6)]
      amount_fields = [
        "Institutionelle Zuwendungen Bremens",
        "Projekt-förderungen Bremens",
        "institutionelle Förderung / Projektförderung Dritter",
      ]

      # iterate over data rows
      3.upto(sheet.last_row).each do |line|
        years.each_with_index do |year,i|
          amount = amount_fields.map{|col| sheet.cell(line, columns[col]+i) }.compact.sum
          if amount != 0
            update_donation(
              number:     "#{year}-#{line}",
              recipient:  sheet.cell(line, columns['Zuwendungsempfänger']),
              donor:      sheet.cell(line, columns['Ressort']),
              purpose:    sheet.cell(line, columns['Zuwendungszweck']),
              date_begin: "#{year}-01-01",
              date_end:   "#{year}-12-31",
              amount:     amount,
              kind:       KINDS[sheet.cell(line, columns['Finanzierungsart'])].to_s,
            )
          end
        end
      end
    end

    def import_2017(sheet)
      year = sheet.cell(3,2)
      raise "invalid year: #{year}" if year !~ /\A20\d\d\z/

      columns = sheet.first_column.upto(sheet.last_column).map do |i|
        if text = sheet.cell(7,i)
          [
            text.gsub(/-?\n/,"").strip,
            i,
          ]
        end
      end.compact.to_h

      # iterate over data rows
      8.upto(sheet.last_row).each do |line,i|
        gkz = sheet.cell(line, columns['GKZ'])
        next unless gkz

        update_donation(
          number:     gkz,
          recipient:  sheet.cell(line, columns['Antragsteller / Zuwendungsempfänger']),
          donor:      sheet.cell(line, columns['Ressort/Dienststelle']),
          purpose:    sheet.cell(line, columns['Zuwendungszweck']),
          date_begin: "#{year}-01-01",
          date_end:   "#{year}-12-31",
          amount:     sheet.cell(line, columns['Zuwendungssumme']),
          kind:       KINDS[sheet.cell(line, columns['Finanzierungsart'])].to_s,
        )
      end
    end

  end
end
