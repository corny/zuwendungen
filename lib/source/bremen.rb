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
      [
        # 2012/2013
        "https://ssl5.bremen.de/transparenzportal/sixcms/media.php/13/OpenData_Zuwendungsbericht%202013.xlsx",
        # 2014/2015
        "https://ssl5.bremen.de/transparenzportal/sixcms/media.php/13/2016-07-12_Zuwendungsbericht_2015_OpenData.xlsx"
      ]
    end

    def import(path)
      sheet = SimpleSpreadsheet::Workbook.read(path)

      if sheet.cell(1,7)=="institutionelle Zuwendungen Bremens 2012" && sheet.cell(1,8)=="institutionelle Zuwendungen Bremens 2013"
        import_2013(sheet)
      elsif sheet.cell(1,5)=="Institutionelle Zuwendungen Bremens" && sheet.cell(1,6).nil?
        import_2015(sheet)
      else
        raise ArgumentError, "unsupported data"
      end
    end

    def import_2013(sheet)
      # map column names to column numbers
      columns = sheet.first_column.upto(sheet.last_column).map{|i| [sheet.cell(1,i), i] }.to_h

      year_fields = [2012, 2013].map do |year|
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
          if amount != 0
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
    end

    def import_2015(sheet)
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

  end
end
