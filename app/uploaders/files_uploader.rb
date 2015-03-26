class FilesUploader < CarrierWave::Uploader::Base
  def store_dir
    if Rails.env.test?
      "uploads/#{Rails.env}/"
    else
      'uploads/'
    end
  end
end
