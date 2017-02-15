class FormUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def store_dir
    "uploads/forms/#{model.id}"
  end

  def extension_white_list
    %w(pdf)
  end

end
