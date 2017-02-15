# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def store_dir
    "uploads/person/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process :resize_to_limit => [100, 100]
  end
end
