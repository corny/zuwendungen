require 'net/http'

module Source
  class Base

    def logger
      Rails.logger
    end

    def state
      self.class.name.split("::")[1]
    end

    def directory
      Rails.root.join("public/data", state).tap(&:mkpath)
    end

    def download_all
      urls.each do |filename,url|
        file = directory.join(filename)
        if file.exist?
          logger.info "[#{state}] File exists: #{file}"
        else
          logger.info "[#{state}] Downloading #{url}"
          res = Net::HTTP.get_response(URI(url))
          raise res.error! unless res.is_a?(Net::HTTPSuccess)
          file.open("wb"){|f| f << res.body }
        end
      end
    end

    def import_file(path)
      logger.info "[#{state}] Importing #{path}"
      import path
    end

    def import_all
      # skip hidden files
      directory.children.sort.reject{|c| c.basename.to_s.starts_with?('.') }.each do |entry|
        import_file entry
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
