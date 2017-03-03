module Source
  class Hamburg < Base

    def urls
      {
        "2010.xlsx" => "https://www.hamburg.de/contentblob/4292692/1463ba5948cc4ba386b5bbca417abd73/data/zuwendungsbericht-2011.xlsx",
        "2012.xlsx" => "http://www.hamburg.de/contentblob/4284536/data/zuwendungsbericht-2013.xlsx",
        "2014.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/ac8c10a8-0d85-4f78-a37d-0a8bf31b1038/Zuwendungsvorgaenge_2014.xlsx",
        "2015-Q1.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/e1c3783d-a43e-45ea-b7ea-d38b1b850728/Zuwendungsvorgaenge_2015_Quartal_1.xlsx",
        "2015-Q2.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/d3fb7456-6f4b-4aec-8b13-f770960ecd69/Zuwendungsvorgaenge_2015_Quartal_2.xlsx",
        # "2015-Q3.xlsx" => "",
        "2015-Q4.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/2fa6afe0-d5a2-4eb8-a115-e235efe618bb/Zuwendungsvorgaenge_2015_Quartal_4.xlsx",
        "2016-Q1.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/2417b6a3-e293-4bce-898a-d8e0c671ea69/Zuwendungsvorgaenge_2016_Quartal_1.xlsx",
        "2016-Q2.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/d39e663a-fd12-4dd6-b27c-cfdfbe673564/Zuwendungsvorgaenge_2016_Quartal_2.xlsx",
        "2016-Q3.xlsx" => "http://daten.transparenz.hamburg.de/Dataport.HmbTG.ZS.Webservice.GetRessource100/GetRessource100.svc/6d17cea7-f22b-4a57-a58b-7b681bca9cea/Zuwendungsvorgaenge_2016_Quartal_3.xlsx",
      }
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
        text = sheet.cell(line,i)

        if text.is_a?(String)
          text = Nokogiri::HTML(sheet.cell(2,8)).text if text.starts_with?("<html>")

          # "Zuwendung für … (ggf. gekürzt)" => "Zuwendnug für"
          text = text.sub(/\A([[:alpha:]\. -]+)(.*)\z/m,"\\1").strip
        end

        [text, i]
      end.to_h


      # iterate over data rows
      (line+1).upto(sheet.last_row).each do |line|
        update_donation(
          number:     sheet.cell(line, columns['INEZ-Nummer'] || columns['AKZNummer']),
          recipient:  sheet.cell(line, columns['Zuwendungsempfänger']),
          donor:      sheet.cell(line, columns['Behörde']),
          purpose:    sheet.cell(line, columns['Zuwendung für'] || columns['Zuwendungszweck']),
          date_begin: sheet.cell(line, columns['Zeitraum Von']  || columns['ZuwendungszeitraumVon']),
          date_end:   sheet.cell(line, columns['Zeitraum Bis']  || columns['ZuwendungszeitraumBis']),
          amount:     sheet.cell(line, columns['Gesamtzuwendung'] || columns['Zuwendungssumme']),
          kind:       sheet.cell(line, columns['Förderungsart']),
        )
      end
    end

  end
end
