require 'sidekiq'

module CarrierWave
  module Storage

    class GoogleDriveUploaderWorker
  
      include Sidekiq::Worker
  
      def perform(file_path, google_login, google_password, model_klassname, model_id, mounted_as)
        @remote_file = connection(google_login, google_password).upload_from_file(file_path, nil, :convert => false)
        @remote_file.acl.push( {:scope_type => "default", :role => "reader"})
        @resource_id = @remote_file.resource_id.split(':').last
        
        record = model_klassname.constantize.find(model_id)
        uploader = record.send(:mounted_as)
        uploader.key = @resource_id
        uploader.updatemodel(nil)
        
        @resource_id
      end
      
      def connection(google_login, google_password)
        @connection ||= ::GoogleDrive.login( google_login, google_password )
      end
  
    end
    
  end
  
end