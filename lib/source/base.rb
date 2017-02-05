module Source
  class Base

    def logger
      Rails.logger
    end

    def state
      self.class.name.split("::")[1]
    end

    def directory
      Rails.root.join("tmp/downloads", state).tap(&:mkpath)
    end

    def download_all
      urls.each do |url|
        uri  = URI(url)
        file = directory.join(File.basename(uri.path))
        if file.exist?
          logger.info "[#{state}] File exists: #{file}"
        else
          logger.info "[#{state}] Downloading #{url}"
          res = Net::HTTP.get_response(uri)
          raise res.error! unless res.is_a?(Net::HTTPSuccess)
          file.open("wb"){|f| f << res.body }
        end
      end
    end

    def import_all
      # skip hidden files
      directory.children.sort.reject{|c| c.basename.to_s.starts_with?('.') }.each do |entry|
        import(entry)
      end
    end

    def update_donation(attributes)
      Donation.transaction do
        Donation.find_or_initialize_by(
          state:  state,
          number: attributes[:number],
        ).update_attributes! attributes
      end
    end
  end
end
