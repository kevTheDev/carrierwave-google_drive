require 'sidekiq'

module CarrierWave
  module Storage

    class GoogleDriveUploaderWorker
  
      include Sidekiq::Worker
  
      # def perform(uploader, storage, file)
      #   f = CarrierWave::Storage::GoogleDrive::File.new(uploader, storage)
      #   f.store(file)
      #   f
      # end
      
      def perform(file_path, google_login, google_password)
        @remote_file = connection(google_login, google_password).upload_from_file(file_path, nil, :convert => false)
        @remote_file.acl.push( {:scope_type => "default", :role => "reader"})
        @resource_id = @remote_file.resource_id.split(':').last
        #@uploader.key = @remote_file.resource_id.split(':').last
        @resource_id
      end
      
      def connection(google_login, google_password)
        @connection ||= ::GoogleDrive.login( google_login, google_password )
      end
  
    end
    
  end
  
end